# %% imports
import numpy as np
import mne
from mne.coreg import Coregistration
from os.path import join
from os import listdir
import glob

# %% define path with raw meg
raw_path = 'raw_data'

# path where you save the headmodels
save_path = '/headmodels/'

# folder where you ger subj names
data_path = 'preprocessed'

# path  with fs average template
mri_path = '/fsaverage'
fs_path = join(mri_path, 'fsaverage')
trans = 'fsaverage'  # MNE has a built-in fsaverage transformation
# src = join(fs_path, 'bem', 'fsaverage-ico-5-src.fif')
# bem = join(fs_path, 'bem', 'fsaverage-5120-5120-5120-bem-sol.fif')

#%% set subject id
all_subjects = sorted(listdir(data_path))
subject_id = all_subjects[0]

#%% get filename
fname = glob.glob(join(raw_path, '**/%s_block1_trans_sss.fif' % subject_id),
                  recursive=True)

#%% get info for MNE from a random dataset
info = mne.io.read_info(fname[0], verbose=False)
info = mne.pick_info(info, mne.pick_types(info, meg=True))

# set plotting defaults
plot_kwargs = dict(subject=trans, subjects_dir=mri_path,
                   surfaces="head-dense", dig=True, eeg=[],
                   meg='sensors', show_axes=True,
                   coord_frame='meg')
view_kwargs = dict(azimuth=45, elevation=90, distance=0.6,
                   focalpoint=(0., 0., 0.))

# %% set up the coregistration model
coreg = Coregistration(info, trans, mri_path)
fig = mne.viz.plot_alignment(info, trans=coreg.trans, **plot_kwargs)
fig.plotter.add_text('Step 1/4 - Subject ID: ' + subject_id[:-4], color='black')

#%% initial fit with fiducials
coreg.fit_fiducials(verbose=True)
fig = mne.viz.plot_alignment(info, trans=coreg.trans, **plot_kwargs)
fig.plotter.add_text('Step 2/4 - Subject ID: ' + subject_id[:-4], color='black')

# refining with ICP
coreg.fit_icp(n_iterations=6, nasion_weight=2, verbose=True)
fig = mne.viz.plot_alignment(info, trans=coreg.trans, **plot_kwargs)
fig.plotter.add_text('Step 3/4 - Subject ID: ' + subject_id[:-4], color='black')

# omitting bad points
coreg.omit_head_shape_points(distance=5 / 1000)  # distance is in meters

# %% final coregistration fit
coreg.fit_icp(n_iterations=20, nasion_weight=10, verbose=True)
fig = mne.viz.plot_alignment(info, trans=coreg.trans, **plot_kwargs)
fig.plotter.add_text('Step 4/4 - Subject ID: ' + subject_id[:-4], color='black')
mne.viz.set_3d_view(fig, **view_kwargs)

dists = coreg.compute_dig_mri_distances() * 1e3  # in mm
print(f"Distance between HSP and MRI (mean/min/max):\n{np.mean(dists):.2f} mm "f"/ {np.min(dists):.2f} mm / "
      f"{np.max(dists):.2f} mm")

# %% save trans-file
fname_trans = save_path + subject_id[:-4] + '-trans.fif'
mne.write_trans(fname_trans, coreg.trans, overwrite=True)
print('Coregistration done!')