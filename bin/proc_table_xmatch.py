#!/usr/bin/env python
import sys
import os

import pandas

if __name__ == '__main__':

    if not len(sys.argv) > 1:
        print("Usage: {} <table_flux.csv>".format(os.path.basename(sys.argv[0])))
        sys.exit(2)

    table_file = sys.argv[1]

    df = pandas.read_csv(table_file, sep=';')

    df.index.name = 'OBJID'
    df.reset_index(inplace=True)

    from astropy.coordinates import SkyCoord
    from astropy import units
    coords = SkyCoord(df['RA'], df['DEC'], unit=(units.hourangle,units.deg))
    df['RA'] = coords.icrs.ra
    df['DEC'] = coords.icrs.dec

    df['snr'] = df['nufnu_3keV'] / df['nufnu_error_3keV']

    cols = dict(ra='RA', dec='DEC', id='OBJID')

    from astropy.coordinates import Angle
    rad = Angle(7,'arcsec')

    from xmatch import xmatch
    xcat = xmatch(df, df, cols, cols, radius=rad, snr_column='snr')

    match_file = '{}_primary_sources.csv'.format(table_file[:-4])
    xcat.to_csv(match_file)
