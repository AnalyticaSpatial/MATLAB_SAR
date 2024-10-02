# Octave and SAR

It is possible to use this library with Octave. [Apache Xerces](https://xerces.apache.org/mirrors.cgi#binary) will need to be installed and the `javaclasspath.txt` in the main directory needs to be edited to reflect the locations of the XML Java JAR files.

## Running

In the Octave CLI run `addpath(genpath('.'))` to add the functions from this library to your current workspace or if you are not exploring data interactively edit this function to include the path to this library.

```
readerobj = open_cphd_reader('data/my_data.cphd')

```

## Processing example

```
bp_file('data/my_data.cphd', 'data/my-data.sio', 'pulse_range', 1:1000, 'sample_range', 1:1000)

% note the file sizes are different compared to matlab but we can check the meta and arrays of both
```

## Testing

The file sizes from Octave and Matlab are slightly different, it is better to test the metadata and arrays using Python and [SarPy](https://sarpy.readthedocs.io/en/latest/).

```
from sarpy.io.complex.converter import open_complex
import numpy as np

rdr_matlab = open_complex("matlab.sio")
rdr_octave = open_complex("octave.sio)

sicd_matlab_meta = rdr_matlab.sicd_meta
sicd_octave_meta = rdr_octave.sicd_meta

# print both metadata objects and the differences are rounding differences caused by reading the XML into a struct and serializing

matlab_data = rdr_matlab.read_raw()
octave_data = rdr_octave.read_raw()

assert matlab_data.shape == octave_data.shape

np.allclose(matlab_data, octave_data, rtol=0.0001, atol=0.0001) # should print True
```