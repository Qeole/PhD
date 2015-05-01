#!/bin/sh

for SUFFIX in "" "_10J" "_20J" ; do
    RAW=RAW"$SUFFIX"
    MEANS=MEANS"$SUFFIX"
    SRC=SRC"$SUFFIX"

    mkdir -p "$MEANS"
    mkdir -p "$SRC"

    for i in $(ls $RAW) ; do
        OUTDIR="$MEANS"/"$i"
        mkdir -p "$OUTDIR"

        # Compute means for energy × time
        paste "$RAW/$i"/*/e.dat |
        #tail -n +2 |
        awk 'BEGIN {
            print "'$i'"            # keep track of scenarios name
        }
        {
            stddev=0; mean=0;
            for (i=1;i<=NF;i++) {
                if (i%2==0)
                    mean+=$i;
                else
                    stddev+=$i;
            } ;
            print stddev/10/1000, mean/10/1000
        }' > "$OUTDIR/e.mean.dat"

        # Compute detection rate
        paste "$RAW/$i"/*/x.dat |
        awk 'BEGIN { print "'$i'" }
            NR>1 {
            nb=0;
            for (i=1;i<=NF;i++) {
                if (i%2==0)
                    if ("'$i'" ~ /democratic7/)
                        nb+=int($i/14);         # Because 1/7 ~= 14% ; /10 is because we ran 10 instances
                    else
                        nb+=$i/10               # 10%
            }
            if ("'$i'" ~ /democratic/ && NR<=7) # Initial period for democratic methods
                print $1/6, 61                  # node 12 (compromised) has 61 neighbors
            else
                print $1/6, nb/10
            }'  | tee "$OUTDIR/x.mean.dat" |
            awk '{if (NR == 1) {print $0} ; if (NR%6 == 1 && NR > 1) {print $1, nb/6; nb=0} if (NR%6!=1) {nb+=$2}}' > "$OUTDIR/x.mean.minute.dat"
            #awk 'NR==1 {print $0 ; sum=0} ; NR>1 {sum+=$2}; END {print sum/(NR-1)}' # Compute global means
    done

    # Detection for a single instance
    NB="04"
    for i in $(ls $RAW) ; do
        OUTDIR="$MEANS"/"$i"
        awk 'BEGIN { print "'$i'" }
            NR>1 {
            if ("'$i'" ~ /democratic/ && NR<=7)
                print $1/6, 61
            else
                if ("'$i'" ~ /democratic7/)
                    print $1/6, int($2/14)
                else
                    print $1/6, ($2/10)
        }' "$RAW"/$i/*$NB/x.dat > "$OUTDIR/x.one.dat"
    done

    # Nb of nodes alive in time
    if [ "$SUFFIX" = "_10J" -o "$SUFFIX" = "_20J" ] ; then
        for i in "$RAW"/* ; do
            for j in $(ls "$i") ; do
                # We want to extract "Loss time..." but sometimes
                # there is the "ENERGY" part which is put in between :/
                sed -n '/^Loss time:$/,/[0-9]\+ \+0$/p' "$i/$j"/output.dat |
                sed '/ENERGY/,/^NS EXITING.../{s/ENERGY/@@@/;t;d}' |
                sed '/@@@/{N;s/@@@\n//}' |
                awk 'NR>=4 && !/^$/' > /dev/shm/"$j$SUFFIX"
            done
            j=$(ls -1 $i | head -n 1)
            ls -1 /dev/shm/"${j%-*}-"*"$SUFFIX" | xargs paste |
            awk 'BEGIN {
                print 99, 0                # Start with 99 nodes (no CH, no greedy)
            } {
                sum=0;
                for (i=1;i<=20;i++) {
                    if (i%2==1) {
                        if ($i~/^$/)
                            sum+=3800      # Arbitrary value > 3600 for nodes still alive
                        else
                            sum+=$i
                        }
                }
                last=$2
                print $2, sum/10/60
            }
            END {
                if (last > 0)               # if nodes remain, make curve go off the graph
                    print last, 3800/60
            }' > $MEANS/${i##*/}/td.mean.dat
        done

        # Because of course above won't work for static
        for j in $(ls -1 "$RAW/static"/*/"output.dat") ; do
            k=$(echo $j | sed "s=$RAW/static/\(.*\)/output.dat=\1_staticTD.dat=")
            sed -n "/^Dead: \+12/d; /^Dead: / s/,//p" $j | awk '{print $4, 99-NR}' > "/dev/shm/$k"
        done
        ls -1 /dev/shm/*"_staticTD.dat" | xargs paste |
        awk 'BEGIN {
            print 99, 0
        } {
            sum=0;
            for (i=1;i<=20;i++) {
                if (i%2==1) {
                    if ($i~/^$/)
                        sum+=3800
                    else
                        sum+=$i
                    }
            }
            last=$2
            print $2, sum/10/60
        }
        END {
            if (last > 0)
                print last, 3800/60
        }' > $MEANS/static/td.mean.dat
        INIT=$(head -n 2 $MEANS/random/x.mean.dat | awk 'NR==2 {print $2}')
        awk '{print $1-89-(10-'$INIT'), $2}' $MEANS/static/td.mean.dat > "$SRC/DetectionXTime_static.dat"

        # On single instance
        INIT=$(head -n 2 $RAW/random/*$NB/x.dat | sed -n 's/^1 \([0-9]\{1,3\}\)/\1/p')
        sed -n "/^Dead: \+12/d; /^Dead: / s/,//p" "$RAW/static/"*"$NB/output.dat" |
        awk 'BEGIN {print "static"; print 0, '$INIT'/10} {nb='$INIT'/10-NR ; if (nb>=0) {print $4/60, nb}}' > "$MEANS/static/x.one.dat"
    fi

    # Consumption X time
    # Get all of this in a single file
    paste "$MEANS"/*/e.mean.dat |
    # But just keep one log/minute
    awk 'NR%6==2 || NR==1 {print int(NR/6), $0}' > "$SRC/ConsumptionXTime.dat"

    # Mean residual energy
    if [ "$SUFFIX" = "_10J" ] ; then
        paste "$MEANS"/*/e.mean.dat |
        awk 'NR%6==2 || NR==1 {for (i=1; i<=NF; i++) {$i=10-$i} ; print int(NR/6), $0}' > "$SRC/ResidualEnergyXTime.dat"
    fi
    if [ "$SUFFIX" = "_20J" ] ; then
        paste "$MEANS"/*/e.mean.dat |
        awk 'NR%6==2 || NR==1 {for (i=1; i<=NF; i++) {$i=20-$i} ; print int(NR/6), $0}' > "$SRC/ResidualEnergyXTime.dat"
    fi

    # Mean detection rate
    paste "$MEANS"/*/x.mean.dat > "$SRC/DetectionXTime.dat"
    paste "$MEANS"/*/x.mean.minute.dat > "$SRC/DetectionXTime_Minute.dat"
    paste "$MEANS"/*/x.one.dat > "$SRC/DetectionXTime_OneInstance.dat"

    # Nodes alive in time
    if [ "$SUFFIX" = "_10J" -o "$SUFFIX" = "_20J" ] ; then
        paste "$MEANS"/*/td.mean.dat > "$SRC/NodesAliveXTime.dat"
    fi
done

rm "/dev/shm/Sim_"*

# Make graphs \o/
mkdir -p GRAPHS
gnuplot plot_sd_consumptionXtime.gpl
gnuplot plot_sd_consumptionXtime_zoom10.gpl
gnuplot plot_sd_stddevXtime.gpl

gnuplot plot_sd_consumptionXtime_10J.gpl
gnuplot plot_sd_detectionXtime_10J.gpl
gnuplot plot_sd_detectionXtime-single_10J.gpl
gnuplot plot_sd_detectionXtime-minute_10J.gpl
gnuplot plot_sd_nbnodesXtime_10J.gpl

gnuplot plot_sd_consumptionXtime_20J.gpl
gnuplot plot_sd_detectionXtime_20J.gpl
gnuplot plot_sd_detectionXtime-single_20J.gpl
gnuplot plot_sd_detectionXtime-minute_20J.gpl
gnuplot plot_sd_nbnodesXtime_20J.gpl
