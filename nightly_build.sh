#!/bin/bash -l

cd /home/foueri01/ENCODExplorerDataBuild

dt=$(date '+%Y-%m-%dGMT%H:%M:%S');
mkdir $dt
pushd $dt
module load R/R-3.6.0_BioC-3.9
R --vanilla <<'EOF' 1> stdout.log 2> stderr.log
#BiocManager::install("ENCODExplorerData", version="devel", update=TRUE, ask=FALSE)
BiocManager::install("ENCODExplorerData", update=TRUE, ask=FALSE)
library(ENCODExplorerData)

source(system.file("scripts/make-data.R", package="ENCODExplorerData"))
EOF
popd

if [ ! -e $dt/encode_df_full.rda ]
then
    echo "ENCODExplorerData build failed." | mail -s "ENCODExplorerData weekly build failure." \
        -r encodexplorerdata@ls31.genome.ulaval.ca \
        -a $dt/stdout.log -a $dt/stderr.log \
        fournier.eric.2@crchudequebec.ulaval.ca \
        charles.joly-beauparlant@crchudequebec.ulaval.ca
        
    exit
fi

# Get the last two checksums
second_to_last=`ls -d *GMT*/ | sort | tail -n 2 | head -n 1`
last_md5=`md5sum $dt/encode_df_full.rda | awk '{print $1}'`
second_to_last_md5=`md5sum $second_to_last/encode_df_full.rda | awk '{print $1}'`

# If there was no change since last time, remove the directory.
if [ "$last_md5" = "$second_to_last_md5" ]
then
    rm -r $dt
else
    rm -rf /home/foueri01/public_html/ENCODExplorerData/latest
    ln -s /home/foueri01/ENCODExplorerDataBuild/$dt /home/foueri01/public_html/ENCODExplorerData/latest
    ln -s /home/foueri01/ENCODExplorerDataBuild/$dt /home/foueri01/public_html/ENCODExplorerData/$dt
fi
