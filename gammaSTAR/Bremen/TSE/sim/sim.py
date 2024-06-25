import numpy as np
np.int = int
np.float = float
np.complex = complex

import MRzeroCore as mr0
import torch
import matplotlib.pyplot as plt

seq_name = "TSE"

mr0.generate_brainweb_phantoms("brainweb", "3T")
phantom = mr0.VoxelGridPhantom.load("brainweb/subject05_3T.npz")
phantom = phantom.interpolate(64, 64, 32).slices([16])
phantom.plot()
data = phantom.build()

seq = mr0.Sequence.import_file(seq_name + "_mr0.seq")
seq.plot_kspace_trajectory()

graph = mr0.compute_graph(seq, data, 200, 1e-3)
signal = mr0.execute_graph(graph, seq, data)

signal_slice = torch.unsqueeze(torch.tensor([]), dim = 1)

N_read = 512
N_phase = 256
N_slices = 11
simulated_slice = 6
echo_train_length = 8

for i in range(0, int(N_phase/echo_train_length)):
    signal_slice = torch.cat((signal_slice,
                              signal[(0
                                      +(simulated_slice*echo_train_length*N_read)
                                      +(i*(N_slices*echo_train_length*N_read))):((echo_train_length*N_read)
                                                                                 +(simulated_slice*echo_train_length*N_read)
                                                                                 +(i*(N_slices*echo_train_length*N_read)))]))

signal_sorted = torch.unsqueeze(torch.tensor([]), dim = 1)
for i in range(0, echo_train_length):
    for j in range(i, N_phase, echo_train_length):
        signal_sorted = torch.cat((signal_sorted, signal_slice[j*N_read:j*N_read+N_read]))

kspace = signal_sorted.view(N_phase, N_read)
reco = torch.fft.fftshift(torch.fft.ifft2(torch.fft.fftshift(kspace)))[:, int(N_read/4):int(3*N_read/4)]

plt.figure()
plt.imshow(reco.abs(), origin="lower", cmap="grey")
plt.gca().invert_xaxis()
plt.gca().invert_yaxis()

plt.show()