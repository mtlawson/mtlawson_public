[ -e ~/scr/simdata/flex_sim2_input_matrix.txt ] && rm ~/scr/simdata/flex_sim2_input_matrix.txt

for i in {1..100}
do
	for met in "rlt" "owl"
	do
		for antag in 0 1
		do
			for dist1 in 1 3 10
			do
				for dist2 in 1 3 10
				do 
					echo "~/flex ~/scr ~/scr/simdata ~/submits $antag $met $dist1 $dist2 $i" >> ~/scr/simdata/flex_sim2_input_matrix.txt
				done
			done
		done
	done
done
