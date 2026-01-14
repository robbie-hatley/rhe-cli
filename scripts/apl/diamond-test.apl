#!/usr/bin/apl --script
⍝ Overall diamond width:
size←25

⍝ Ascending star counts: 1 3 5 ... up to size
up   ← (2×⍳⌈size÷2) - 1

⍝ Descending star counts: ... size-2 down to 1
down ← ⌽ (2×⍳⌈(size-2)÷2) - 1

widths ← up , down

⍝ Monadic row function: right arg = number of stars, uses global 'size'
row ← { ((size-⍵)÷2)⍴' ' , ⍵⍴'*' , ((size-⍵)÷2)⍴' ' }

⎕← ↑ row¨widths

)OFF
