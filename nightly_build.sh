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
    mail -s "Error while regenerating encode_df" fournier.eric.2@crchudequebec.ulaval.ca < /dev/null
    exit
fi

# Get the last two checksums
second_to_last=`ls -d *GMT*/ | sort | tail -n 2 | head -n 1`
last_md5=`md5sum $dt/encode_df_full.rda | awk '{print $1}'`
second_to_last_md5=`md5sum $second_to_last/encode_df_full.rda | awk '{print $1}'`

# If there was no change since last time, remove the directory.
if [ "$last_md5" = "$second_to_last_md5" ]
#    rm -r $dt
    echo "Would remove."
else
    rm -rf ~/public_html/ENCODExplorerData/latest
    ln -s ~/ENCODExplorerDataBuild/$dt ~/public_html/ENCODExplorerData/latest
    ln -s ~/ENCODExplorerDataBuild/$dt ~/public_html/ENCODExplorerData/$dt
fi