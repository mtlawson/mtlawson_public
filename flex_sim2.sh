while read arg;
do
	outname=$( echo $arg | awk '{print "~/scr/simdata/sim2_out_ant"$5"_"$6"_"$7"_"$8"_"$9".rda"}' )
	echo $outname
	jobname=$( echo $arg | awk '{print $9$7$8$5}' )
	[ -e $outname ] && rm $outname 
	sbatch -o boot_pt.out -t 0-04:00:00 --mem=20000 --job-name=$jobname --wrap "Rscript ~/flex/flex_sim2_rscript.R $arg"
done < ~/scr/simdata/flex_sim2_input_matrix.txt