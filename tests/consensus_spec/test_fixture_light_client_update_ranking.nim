# beacon_chain
# Copyright (c) 2022 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at https://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at https://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

{.used.}

# This implements the pre-release proposal of the libp2p based light client sync
# protocol. See https://github.com/ethereum/consensus-specs/pull/2802

# These tests are for the pre-release proposal of the libp2p based light
# client sync protocol. Corresponding test vectors need manual integration.
# https://github.com/ethereum/consensus-specs/pull/2802
#
# To locally integrate the test vectors, clone the pre-release spec repo
# at latest commit of https://github.com/ethereum/consensus-specs/pull/2802
# and place it next to the `nimbus-eth2` repo, so that `nimbus-eth2` and
# `consensus-specs` are in the same directory.
#
# To generate the additional test vectors, from `consensus-specs`:
# $ rm -rf ../consensus-spec-tests && \
#   doctoc specs && make lint && make gen_light_client
#
# To integrate the additional test vectors into `nimbus-eth2`, first run
# `make test` from `nimbus-eth2` to ensure that the regular test vectors
# have been downloaded and extracted, then proceed from `nimbus-eth2` with:
# $ rsync -r ../consensus-spec-tests/tests/ \
#   ../nimbus-eth2/vendor/nim-eth2-scenarios/tests-v1.2.0-rc.1/

import
  # Standard library
  std/[algorithm, os, streams],
  # Status libraries
  stew/base10,
  # Third-party
  yaml,
  # Beacon chain internals
  ../../../beacon_chain/spec/helpers,
  ../../../beacon_chain/spec/datatypes/altair,
  # Test utilities
  ../testutil,
  ./fixtures_utils

type
  TestMeta = object
    updates_count: uint64

proc runTest(path: string) =
  test "Light client - Update ranking - " & path.relativePath(SszTestsDir):
    let meta = block:
      var s = openFileStream(path/"meta.yaml")
      defer: close(s)
      var res: TestMeta
      yaml.load(s, res)
      res

    var updates = newSeqOfCap[altair.LightClientUpdate](meta.updates_count)
    for i in 0 ..< meta.updates_count:
      updates.add parseTest(
        path/"updates_" & Base10.toString(i) & ".ssz_snappy",
        SSZ, altair.LightClientUpdate)

    proc cmp(a, b: altair.LightClientUpdate): int =
      if a.is_better_update(b):
        check: not b.is_better_update(a)
        -1
      elif b.is_better_update(a):
        1
      else:
        0
    check: updates.isSorted(cmp)

suite "EF - Light client - Update ranking" & preset():
  const presetPath = SszTestsDir/const_preset
  for kind, path in walkDir(presetPath, relative = true, checkDir = true):
    let basePath =
      presetPath/path/"light_client"/"update_ranking"/"pyspec_tests"
    if kind != pcDir or not dirExists(basePath):
      continue
    for kind, path in walkDir(basePath, relative = true, checkDir = true):
      runTest(basePath/path)
