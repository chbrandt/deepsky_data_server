#!/usr/bin/env python
import sys
import os

import pandas
import numpy
import astropy


SEP = ';'


def designation(ra, dec):
    from astropy import coordinates as coord
    assert all(isinstance(c, coord.Angle) for c in [ra, dec])

    ras = ra.to_string(unit='hourangle', decimal=False, pad=True,
                        precision=1, fields=3, alwayssign=False, sep='')
    decs = dec.to_string(unit='degree', decimal=False, pad=True,
                        precision=1, fields=3, alwayssign=True, sep='')

    desig = list(map(lambda a, b: 'SDSX_J{}{}'.format(a, b), ras, decs))
    return desig


def reorder_columns(df):
    first_cols = ['OBJID','RA','DEC','NAME']
    cols_reordered = first_cols[:]
    cols_reordered.extend(c for c in df.columns if c not in first_cols)
    return df[cols_reordered]


def normalize_column_names(df):
    import re
    nc = []
    for c in df.columns:
        c = c.upper()
        mat = re.search(r'(?<=_)\d.*K(?=EV)',c)
        if not mat:
            nc.append(c)
            continue
        # print("Changing column: {}".format(c))
        val = mat.group(0)[:-1]
        try:
            val = float(val)
            val = int(1000*val)
        except ValueError:
            if val == '0.3-10':
                val = '300_10000'
            elif val == '0.3-1':
                val = '300_1000'
            elif val == '1-2':
                val = '1000_2000'
            elif val == '2-10':
                val = '2000_10000'
            else:
                val = val
        _nc = re.sub(r'(?<=_)\d.*K(?=EV)','{}'.format(val), c)
        # print("to: {}".format(_nc))
        nc.append(_nc)
    df.columns = nc
    return df


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

    # Give a name to the objects
    df_tmp['NAME'] = designation(coords.icrs.ra, coords.icrs.dec)

    # Reorder columns
    df_tmp = reorder_columns(df_tmp)

    # Normalize (upper case without '.' or '-')
    df_tmp = normalize_column_names(df_tmp)

    df_tmp['SNR'] = df_tmp['EXPOSURE_TIME'] + (df_tmp['NUFNU_3000EV'] / df_tmp['NUFNU_ERROR_3000EV'])

    if df_final is not None:
        min_index = df_final['OBJID'].max() + 1
        df_tmp['OBJID'] = numpy.arange(min_index, len(df_tmp)+min_index)
        df = pandas.concat([df_final, df_tmp], axis=0, ignore_index=True, sort=False)
    else:
        df = df_tmp

    cols = dict(ra='RA', dec='DEC', id='OBJID')

    from astropy.coordinates import Angle
    rad = Angle(7, 'arcsec')

    from xmatch import xmatch
    xcat = xmatch(df, df, cols, cols, radius=rad, snr_column='SNR')

    df_xcat = df.set_index('OBJID').loc[xcat[('B','OBJID')].astype(int)]
    df_xcat.reset_index(inplace=True)

    df_xcat.to_csv(table_file_out, sep=SEP, index=False, float_format='%g')
