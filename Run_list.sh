#!/bin/sh

cd `dirname $0`
chmod 755 ./bin/*
xattr -dr com.apple.quarantine ./bin

# Project settings
NumThreads=4
InferenceMode=3

# Other settings
SUFFIX=musicxml
StyleShift=1
PitchShiftNsf=0
PitchShiftWorld=0
FormantShift=1.5
SmoothPitch=0.0
SmoothFormant=0.0
EnhanceBreathiness=0.0

export DYLD_LIBRARY_PATH=$PWD/bin:$DYLD_LIBRARY_PATH

# List of basenames and modeldirs to loop through
BASENAMES=("wsurenaideokuue")
MODELDIRS=("KIRITAN" "ZUNDAMON")

for BASENAME in "${BASENAMES[@]}"; do
    for ModelDir in "${MODELDIRS[@]}"; do
        if [ ${InferenceMode} -eq 4 ]; then
            NsfModel=va
            SamplingFreq=48
        elif [ ${InferenceMode} -eq 3 ]; then
            NsfModel=vs
            SamplingFreq=48
        elif [ ${InferenceMode} -eq 2 ]; then
            NsfModel=ve
            SamplingFreq=24
        fi

        echo "`date +"%M:%S"` : start MusicXMLtoLabel"
        ./bin/musicXMLtoLabel score/musicxml/${BASENAME}.${SUFFIX} score/label/full/${BASENAME}.lab score/label/mono/${BASENAME}.lab

        echo "`date +"%M:%S"` : start NEUTRINO"
        ./bin/NEUTRINO score/label/full/${BASENAME}.lab score/label/timing/${BASENAME}.lab ./output/${BASENAME}.f0 ./output/${BASENAME}.melspec ./model/${ModelDir}/ -w ./output/${BASENAME}.mgc ./output/${BASENAME}.bap -n 1 -o ${NumThreads} -k ${StyleShift} -d ${InferenceMode} -t

        echo "`date +"%M:%S"` : start NSF"
        ./bin/NSF output/${BASENAME}.f0 output/${BASENAME}.melspec ./model/${ModelDir}/${NsfModel}.bin output/${BASENAME}_${ModelDir}.wav -l score/label/timing/${BASENAME}.lab -n 1 -p ${NumThreads} -s ${SamplingFreq} -f ${PitchShiftNsf} -t

        echo "`date +"%M:%S"` : start WORLD"
        # ./bin/WORLD output/${BASENAME}.f0 output/${BASENAME}.mgc output/${BASENAME}.bap output/${BASENAME}_world.wav -f ${PitchShiftWorld} -m ${FormantShift} -p ${SmoothPitch} -c ${SmoothFormant} -b ${EnhanceBreathiness} -n ${NumThreads} -t

        echo "`date +"%M:%S"` : END"
    done
done
