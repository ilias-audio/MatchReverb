function [x_early, x_late] = splitEarlyLate(signal_struct)
    st = signal_struct;

% for now, we do a simple cut at 80 ms
lastSamp = round(st.SAMPLE_RATE* st.EDT);
x_early = st.SIGNAL(1:lastSamp);
x_late = st.SIGNAL(lastSamp+1:length(st.SIGNAL));