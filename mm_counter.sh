#!/usr/bin/sh

# count mismatches in a fasta alignment of sequences; file is single line fasta aligned to reference genome seq; the reference for mismatch counting is the primer of interest, output is a tab delimited file showing the counts per position of the nucleotides of the primer in the alignment
# run as sh counter.sh filename #

file=$1
name=`echo $file | cut -d'_' -f1`;

# count the number of bases to trim upstream of the primer sequence
x=`awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $file | grep -e 'FOR' -e 'REV' -e 'PROBE' | cut -f2 | awk -F'[^-]' '{print length($1)}'`;
front=$(( $x + 1 ));

# count the number of bases to trim downstream from the end of the primer sequence
y=`awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $file |  grep -e 'FOR' -e 'REV' -e 'PROBE' | cut -f2 | cut -c$front- | awk -F'[^atgcATGC]' '{print length($1)}'`;

# keep the headers of the fasta sequences
awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $file | cut -f1 | sed -e 's/>//g' >headers;

# trim the sequences in the alignment and subsitute gaps with 'd' or non-sequenced (e.g., n's) bases with 'x'
awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $file | cut -f2 | cut -c$front- | cut -c1-$y | sed -e 's/\-/d/g' | sed -e 's/N/x/g' >ftrim;

primer_array=();
seq_array=();

# populate an array with the bases in the primer sequence
primer=`awk 'BEGIN{RS=">"}NR>1{sub("\n","\t"); gsub("\n",""); print RS$0}' $file | grep -e 'FOR' -e 'REV' -e 'PROBE' | cut -f2 | cut -c$front- | cut -c1-$y`;
primer_array=( `echo $primer | grep -o . ` );

# read through the alignment file with the trimmed sequences and count the mismatches to the primer sequence
while read line;
do
    seq_array=( `echo $line | grep -o . ` ); # populate an array with bases in the variant sequence
    result_array=();
    len=${#seq_array[@]};
    counter=();
    for (( i=0; i<$len; i++));
    do
	if [ "${seq_array[$i]}" == "x" ];
	then result='NA'; # if base is not sequenced, cannot say there is a mismatch or not
	else
        if [ "${seq_array[$i]}" == "d" ];
        then result='del'; # if base is a gap, then indicate it's a deletion
        else
            if [ "${seq_array[$i]}" == "${primer_array[$i]}" ];
            then result=0; # 0 reflects no mismatch
            else result=1; # 1 reflects mismatch at position
            fi;
        fi;
    fi;
	result_array+=($result);
	num=$(( $i + 1 ));
	counter+=($num);
    done;

    echo ${result_array[@]} | sed 's/ /\t/g' >>numbers;
    
done < ftrim;

echo ${counter[@]} | sed 's/ /\t/g' >tmp;
cat tmp numbers >counts;

echo "primer_position\n$(cat headers)" >headers2;

paste headers2 counts >$name"_mm-ct.txt"; #output file is tab-delimited file with mismatches identified by position for each sequence in the original alignment file

rm tmp;
rm numbers;
rm headers;
rm headers2;
rm counts;
rm ftrim;
