import mne
import numpy as np
from datetime import datetime
from os import listdir
from os.path import join

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
