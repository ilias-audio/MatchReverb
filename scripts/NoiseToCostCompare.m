load('/Users/ilias/Documents/github/MatchReverb/debug/generated/measures/gen_stalbans_omni_measures.mat')


noise = 10^(-80/20) * (rand(size(measures.SIGNAL)) - 0.5);

cost = CompareImpulseResponsesSpectrograms(measures, measures.SIGNAL + noise);

fprintf("[LOG] Local Cost: %f \n", cost);
