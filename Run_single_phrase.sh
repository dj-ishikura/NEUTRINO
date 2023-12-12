#!/bin/sh
cd `dirname $0`
chmod 755 ./bin/*
xattr -dr com.apple.quarantine ./bin

# Project settings
BASENAME=sample1
NumThreads=4
InferenceMode=3
PhraseNum=1

# musicXML_to_label
SUFFIX=musicxml

# NEUTRINO
ModelDir=MERROW
StyleShift=0

# NSF
PitchShiftNsf=0

# WORLD
PitchShiftWorld=0
FormantShift=1.0
SmoothPitch=0.0
SmoothFormant=0.0
EnhanceBreathiness=0.0

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

# PATH to current library
export DYLD_LIBRARY_PATH=$PWD/bin:$DYLD_LIBRARY_PATH

echo "`date +"%M:%S"` : start MusicXMLtoLabel"
./bin/musicXMLtoLabel score/musicxml/${BASENAME}.${SUFFIX} score/label/full/${BASENAME}.lab score/label/mono/${BASENAME}.lab

echo "`date +"%M:%S"` : start NEUTRINO"
./bin/NEUTRINO score/label/full/${BASENAME}.lab score/label/timing/${BASENAME}.lab ./output/${BASENAME}.f0 ./output/${BASENAME}.melspec ./model/${ModelDir}/ -w ./output/${BASENAME}.mgc ./output/${BASENAME}.bap -i output/${BASENAME}-phraselist.txt -p ${PhraseNum} -n 1 -o ${NumThreads} -k ${StyleShift} -d ${InferenceMode} -t

echo "`date +"%M:%S"` : start NSF"
./bin/NSF output/${BASENAME}.f0 output/${BASENAME}.melspec ./model/${ModelDir}/${NsfModel}.bin output/${BASENAME}-${PhraseNum}.wav -n 1 -p ${NumThreads} -s ${SamplingFreq} -f ${PitchShiftNsf} -t

echo "`date +"%M:%S"` : start WORLD"
./bin/WORLD output/${BASENAME}.f0 output/${BASENAME}.mgc output/${BASENAME}.bap output/${BASENAME}-${PhraseNum}_world.wav -f ${PitchShiftWorld} -m ${FormantShift} -p ${SmoothPitch} -c ${SmoothFormant} -b ${EnhanceBreathiness} -n ${NumThreads} -t

echo "`date +"%M:%S"` : END"
