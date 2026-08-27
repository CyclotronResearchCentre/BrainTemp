function step3_fft_info(in)
% STEP3_FFT_INFO
% Step 3 is the Fourier transform.
% In FID-A/Osprey structures, the frequency-domain signal is usually already
% stored in the .specs field, so this function simply checks availability.

    if isfield(in, 'specs')
        fprintf('FFT is available in the .specs field.\n');
    else
        warning('No .specs field found. FFT may not be available.');
    end
end