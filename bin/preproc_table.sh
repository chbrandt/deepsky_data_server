#!/usr/bin/env bash
set -ue

## The table we are going to handle here is sampled below:
#
# #RA;DEC;NH;ENERGY_SLOPE;ENERGY_SLOPE_ERROR;EXPOSURE_TIME;nufnu_3keV(erg.s-1.cm-2);nufnu_error_3keV(erg.s-1.cm-2);nufnu_0.5keV(erg.s-1.cm-2);nufnu_error_0.5keV(erg.s-1.cm-2);upper_limit_0.5keV(erg.s-1.cm-2);nufnu_1.5keV(erg.s-1.cm-2);nufnu_error_1.5keV(erg.s-1.cm-2);upper_limit_1.5keV(erg.s-1.cm-2);nufnu_4.5keV(erg.s-1.cm-2);nufnu_error_4.5keV(erg.s-1.cm-2);upper_limit_4.5keV(erg.s-1.cm-2)
# 00:04:47.523;-00:25:03.225;2.97E+20;0.8;-999/-999;3796.9;3.73977e-14;1.52361e-14;3.3449e-14;1.99876e-14;-9.990E+02;2.39967e-14;2.00785e-14;-9.990E+02;3.63737e-14;3.04345e-14;-9.990E+02
# 00:05:33.568;-00:27:56.900;3.02E+20;0.8;-999/-999;3759.7;4.35675e-14;1.665e-14;3.90242e-14;-2.98215e-11;1.29036e-13;5.58559e-14;3.08346e-14;-9.990E+02;8.46214e-14;4.67143e-14;-9.990E+02
# #RA;DEC;NH;ENERGY_SLOPE;ENERGY_SLOPE_ERROR;EXPOSURE_TIME;nufnu_3keV(erg.s-1.cm-2);nufnu_error_3keV(erg.s-1.cm-2);nufnu_0.5keV(erg.s-1.cm-2);nufnu_error_0.5keV(erg.s-1.cm-2);upper_limit_0.5keV(erg.s-1.cm-2);nufnu_1.5keV(erg.s-1.cm-2);nufnu_error_1.5keV(erg.s-1.cm-2);upper_limit_1.5keV(erg.s-1.cm-2);nufnu_4.5keV(erg.s-1.cm-2);nufnu_error_4.5keV(erg.s-1.cm-2);upper_limit_4.5keV(erg.s-1.cm-2)
# 02:42:25.264;+00:58:20.706;3.16E+20;0.8;-999/-999;15238.5;2.0075e-14;5.29758e-15;9.87538e-15;4.98546e-15;-9.990E+02;1.86631e-14;8.24284e-15;-9.990E+02;2.82332e-14;1.24696e-14;-9.990E+02
# 02:42:40.331;+00:57:26.002;3.18E+20;1.005;+0.08/-0.08;15192.9;4.21477e-13;1.86288e-14;3.75051e-13;2.56272e-14;-9.990E+02;4.8011e-13;3.42416e-14;-9.990E+02;4.16177e-13;3.8457e-14;-9.990E+02
# 02:42:38.886;+01:02:29.122;3.27E+20;0.8;-999/-999;11787.8;1.5811e-14;5.45688e-15;1.43205e-14;7.12983e-15;-9.990E+02;6.71911e-15;5.82703e-15;-9.990E+02;2.03013e-14;1.22239e-14;-9.990E+02
# 02:42:14.497;+00:55:03.700;3.15E+20;0.8;-999/-999;14262.9;1.03684e-14;4.32016e-15;3.11513e-15;3.17793e-15;-9.990E+02;1.32515e-14;7.88892e-15;-9.990E+02;1.33643e-14;9.54746e-15;-9.990E+02
# 02:42:54.681;+00:54:55.466;3.19E+20;0.8;-999/-999;12478.1;1.59087e-14;5.44245e-15;1.91512e-14;8.0032e-15;-9.990E+02;9.03346e-15;6.55585e-15;-9.990E+02;6.8309e-15;6.90638e-15;-9.990E+02
# 02:42:01.695;+00:54:09.078;3.13E+20;0.8;-999/-999;13977.0;1.7686e-14;5.5704e-15;1.15833e-14;6.13029e-15;-9.990E+02;2.05693e-14;9.69685e-15;-9.990E+02;1.24476e-14;9.28313e-15;-9.990E+02
#
# We want to fix column names and remove unwanted entries from the table

function clean_headline () {
  local FILE="$1"

  # Remove comment char '#' from first line
  EXPR1='1,1s/^#//'

  # Remove unit information
  EXPR2='1,1s/\([^)]*\)//g'

  sed -i.BKP_head -E -e "$EXPR1" -e "$EXPR2" $FILE
}

function clean_content () {
  local FILE="$1"

  # Exempt first line from this cleaning (this is clean_headline's job)
  # EXPR1='1p'

  # Remove comment '#' lines
  EXPR2='/^#/d'

  # sed -i.BKP_cont -E -e "$EXPR1" -e "$EXPR2" $FILE
  sed -i.BKP_cont -E "$EXPR2" $FILE
}


# Argument of the script is the table filename
#
CSVTABLE="$1"
cp "$CSVTABLE" "${CSVTABLE}.BKP"

clean_headline "$CSVTABLE"

clean_content "$CSVTABLE"
