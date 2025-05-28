# Target prediction
- Use base PC to select index (hash)
1. Prune last target (if at count)
2. Remove new target
3. Shift targets over
4. Append new target 
- Copy list directly into response

# Branch prediction
1. Record last taken
2. Record number of taken
- Use PC to select index (hash)
- Use local history to select table (hash)
- If number of taken > thresh - no exec_alt
- Prio_taken is equal to last taken

# Pipeline manager
- For each level find two previous and mux them to next level based on result of ex_mem
- The "width" of the pipeline denotes the number of speculative branches can be executed for any given instruction
- The depth of the pipeline is 4 -> if, id, rd, ex