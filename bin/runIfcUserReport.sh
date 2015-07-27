
ts=`perl -e '$_=scalar localtime; tr/ :/-_/; print'`

ssh ctc bin/runIfcUserReport.sh |gunzip> ~/Desktop/ctc.userreport.$ts.csv

