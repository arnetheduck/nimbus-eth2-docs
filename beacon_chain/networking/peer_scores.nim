# beacon_chain
# Copyright (c) 2018-2022 Status Research & Development GmbH
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at https://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at https://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

{.push raises: [Defect].}

const
  NewPeerScore* = 300
    ## Score which will be assigned to newly connected peer
  PeerScoreLowLimit* = 0
    ## Score after which peer will be kicked
  PeerScoreHighLimit* = 1000
    ## Max value of peer's score
  PeerScoreInvalidRequest* = -500
    ## This peer is sending malformed or nonsensical data

  PeerScoreHeadTooNew* = -100
    ## The peer reports a head newer than our wall clock
  PeerScoreNoStatus* = -100
    ## Peer did not answer `status` request.
  PeerScoreStaleStatus* = -50
    ## Peer's `status` answer did not progress in time.
  PeerScoreUseless* = -10
    ## Peer's latest head is lower then ours.
  PeerScoreGoodStatus* = 50
    ## Peer's `status` answer is fine.
  PeerScoreNoBlocks* = -100
    ## Peer did not respond in time to a request.
  PeerScoreGoodBlocks* = 100
    ## Peer's answer to our request is fine.
  PeerScoreBadBlocks* = -1000
    ## Peer's response contains incorrect data.
  PeerScoreBadResponse* = -1000
    ## Peer's response is not in requested range.
  PeerScoreMissingBlocks* = -25
    ## Peer response contains too much missing data - this can happen either
    ## because a long reorg happened or the peer is falsely trying to convince
    ## us that a long reorg happened.
  PeerScoreUnviableFork* = -200
    ## Peer responded with data from an unviable fork - are they on a
    ## different chain?
