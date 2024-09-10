import mne
import numpy as np
from datetime import datetime
from os import listdir
from os.path import join


def preproc_data(cur_data, max_filt=False, notch=True, coord_frame='head',
                 apply_filter=False, hp_lp_freqs=(None, None), do_downsample=False, resample_freq=None):
    """
    Minimal preprocessing function. Only contains some maxfiltering.
    I might add an automatic ICA and autoreject, riemannian potato option
    """

    if isinstance(cur_data, str):
        cur_data = mne.io.read_raw_fif(cur_data, preload=True, verbose=False, on_split_missing='warn')

    if max_filt:
        print('Running maxfilter')
        calibration_file = '/mnt/obob/staff/fschmidt/anonym/assets/maxfilter_cal/sss_cal.dat'
        cross_talk_file = '/mnt/obob/staff/fschmidt/anonym/assets/maxfilter_cal/ct_sparse.fif'

        # find bad channels first
        noisy_chs, flat_chs = mne.preprocessing.find_bad_channels_maxwell(cur_data,
                                                                          coord_frame=coord_frame,
                                                                          calibration=calibration_file,
                                                                          cross_talk=cross_talk_file  # noqa
                                                                          )
        cur_data.info['bads'] = noisy_chs + flat_chs

        cur_data = mne.preprocessing.maxwell_filter(cur_data,
                                                    calibration=calibration_file,
                                                    cross_talk=cross_talk_file,
                                                    coord_frame=coord_frame,
                                                    destination=(0, 0, 0.04) if coord_frame == 'head' else None,  # noqa
                                                    st_fixed=False)

    if apply_filter:
        cur_data.filter(hp_lp_freqs[0], hp_lp_freqs[1], fir_design='firwin')

    if notch:
        cur_data.notch_filter(np.arange(50, 351, 50), filter_length='auto', phase='zero')

    if do_downsample:
        cur_data.resample(resample_freq, npad="auto")

    return cur_data


# Get empty room data that's closest to the actual measurement
def get_nearest_empty_room(info):
    """
    This function finds the empty room file with the closest date to the current measurement.
    The file is used for the noise covariance estimation.
    """
    empty_room_path = '/mnt/sinuhe/data_raw/empty_room/subject_subject'
    all_empty_room_dates = np.array([datetime.strptime(date, '%y%m%d') for date in listdir(empty_room_path)])

    cur_date = info['meas_date']
    cur_date_truncated = datetime(cur_date.year, cur_date.month, cur_date.day)  # necessary to truncate

    def _nearest(items, pivot):
        return min(items, key=lambda x: abs(x - pivot))

    while True:
        nearest_date_datetime = _nearest(all_empty_room_dates, cur_date_truncated)
        nearest_date = nearest_date_datetime.strftime("%y%m%d")

        cur_empty_path = join(empty_room_path, nearest_date)

        # do not use 210115 (styrofoam head fake measurement)
        if cur_empty_path == '/mnt/sinuhe/data_raw/empty_room/subject_subject/210115':
            cur_empty_path = '/mnt/sinuhe/data_raw/empty_room/subject_subject/210114'

        if 'supine' in listdir(cur_empty_path)[0]:
            all_empty_room_dates = np.delete(all_empty_room_dates, all_empty_room_dates == nearest_date_datetime)
        elif '68' in listdir(cur_empty_path)[0]:
            break

    empty_room_data = mne.io.read_raw_fif(join(cur_empty_path, listdir(cur_empty_path)[0]), preload=True)
    # print('Loading of mepty room data with the path: ' + join(cur_empty_path, listdir(cur_empty_path)[0] + ' failed.')

    return empty_room_data
