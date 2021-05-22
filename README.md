# SACOV_primer-probe_analyses
Code for local processing of multisequence alignments to count mismatches with primers and probes.

Code consists of a simple text processing function meant to be run locally on bash terminal. 

Input is a fasta alignment of sequences (including oligo sequence, "FOR", "REV", "PROBE") to reference sequence. Sequences are single-line, not multi-line format.

Code trims sequences to oligo sequence and calls match (0) or mismatch (1) for each sequence at each position aligned to nucleotide order in given oligo. 

If base is not called in sequence (e.g., "N"), mismatch cannot be called and result is 'NA'.
If gap is called due to the fact that the sequence is incomplete / partial, 'del' is resulted.

Output is a tab delimited text file that annotates the header of the sequence and the (mis)match call for each position (e.g., 1, 2, 3...) of the oligo in the given alignment. 

Manual counting of mismatches across positions is performed using output files. 
