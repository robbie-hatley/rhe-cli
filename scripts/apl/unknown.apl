#!/usr/local/bin/apl --script
⍝
⍝ Author:      Bill Daly
⍝ Date:        2019-6-22
⍝ Copyright:   Copyright (C) 2019 by Bill Daly
⍝ License:     GPL see http://www.gnu.org/licenses/gpl-3.0.en.html
⍝ Support email: ??????@??????
⍝ Portability:   L3 (GNU APL)
⍝
⍝ Purpose:
⍝ Initalize ⎕RL with a "true" random seed.
⍝
⍝ Description:
⍝ A function that returns a random seed suitable for initializing ⎕RL
⍝

 ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝
⍝ rl 2019-06-22  13:30:53 (GMT+2)
 ⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

∇seed←rl∆seed;sink
   ⍝ Function reads a seed from /dev/urandom (try man /dev/random)
   fh←⎕FIO[3] '/dev/urandom'
 st:
   seed← (4⍴256)⊥4 ⎕FIO[6] fh
   →(st,ed)[⎕io+ 4294967294>seed]
 ed:
   sink← ⎕FIO[4] fh
∇

⎕CT←1E¯13

⎕FC←(,⎕UCS 46 44 8902 48 95 175)

⎕IO←1

⎕L←0

⎕LX←' ' ⍝ proto 1
  ⎕LX←0⍴⎕LX ⍝ proto 2

⎕PP←10

⎕PR←' '

⎕PS←0 0

⎕PW←80

⎕R←0

⎕RL←16807

⎕TZ←2

⎕X←0


⍝ EOF
