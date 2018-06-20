#!/usr/bin/env python
import sys
import os

import pandas
import numpy

SEP = ';'

if __name__ == '__main__':

    if not len(sys.argv) > 2:
        msg = "Usage: {} <table_flux_in.csv> <filename_out.csv>"
        print(msg.format(os.path.basename(sys.argv[0])))
        sys.exit(2)

    table_file_in = sys.argv[1]
    table_file_out = sys.argv[2]

    # If there is a "FINAL" table, read it to then concatenate both
    #
    df_final = None
    if os.path.isfile(table_file_out):
        df_final = pandas.read_csv(table_file_out, sep=SEP)
        assert "OBJID" in df_final.columns

    # Operate in the "TMP" table, the new one
    #
    df_tmp = pandas.read_csv(table_file_in, sep=SEP)

    df_tmp.index.name = 'OBJID'
    df_tmp.reset_index(inplace=True)

    from astropy.coordinates import SkyCoord
    from astropy import units
    coords = SkyCoord(df_tmp['RA'], df_tmp['DEC'], unit=(units.hourangle, units.deg))
    df_tmp['RA'] = coords.icrs.ra
    df_tmp['DEC'] = coords.icrs.dec

    df_tmp['snr'] = df_tmp['nufnu_3keV'] / df_tmp['nufnu_error_3keV']

    if df_final is not None:
        min_index = df_final['OBJID'].max() + 1
        df_tmp['OBJID'] = numpy.arange(min_index, len(df_tmp)+min_index)
        df = pandas.concat([df_final, df_tmp], axis=0, ignore_index=True)
    else:
        df = df_tmp

    cols = dict(ra='RA', dec='DEC', id='OBJID')

    from astropy.coordinates import Angle
    rad = Angle(7, 'arcsec')

    from xmatch import xmatch
    xcat = xmatch(df, df, cols, cols, radius=rad, snr_column='snr')

    df_xcat = df.set_index('OBJID').loc[xcat[('B','OBJID')].astype(int)]
    df_xcat.reset_index(inplace=True)

    # match_file = '{}_primary_sources.csv'.format(table_file_in[:-4])
    # xcat.to_csv(match_file)
    df_xcat.to_csv(table_file_out, sep=SEP, index=False)
