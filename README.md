[![Zenodo DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.213475.svg)](https://doi.org/10.5281/zenodo.213475)
[![Travis CI](https://travis-ci.org/scivision/lowtran.svg?branch=master)](https://travis-ci.org/scivision/lowtran)
[![Coverage](https://coveralls.io/repos/github/scivision/lowtran/badge.svg?branch=master)](https://coveralls.io/github/scivision/lowtran?branch=master)
[![AppVeyor CI](https://ci.appveyor.com/api/projects/status/85epbcxvbgxnkp62?svg=true)](https://ci.appveyor.com/project/scivision/lowtran)
[![Maintainability](https://api.codeclimate.com/v1/badges/fb6bf9d0351130bba583/maintainability)](https://codeclimate.com/github/scivision/lowtran/maintainability)
[![PyPi version](https://img.shields.io/pypi/pyversions/lowtran.svg)](https://pypi.python.org/pypi/lowtran)
[![PyPi formats](https://img.shields.io/pypi/format/lowtran.svg)](https://pypi.python.org/pypi/lowtran)
[![PyPi Download stats](http://pepy.tech/badge/lowtran)](http://pepy.tech/project/lowtran)

# Lowtran in Python

LOWTRAN7 atmospheric absorption extinction model. 
Updated by Michael Hirsch to be platform independent and easily accessible from Python &ge; 3.6 and Matlab &ge; R2014b.

The main LOWTRAN program has been made accessible from Python by using direct memory transfers instead of the cumbersome and error-prone process of writing/reading text files.
`xarray.Dataset` high-performance, simple N-D array data is passed out, with appropriate metadata.


## Gallery

See below for how to make these examples.

![Lowtran7 absorption](gfx/lowtran.png)

## Install

1. A Fortran compiler such as `gfortran` is needed. 
   We use `f2py` (part of `numpy`) to seamlessly use Fortran libraries from Python.
   If you don't have one, here is how to install Gfortran:
   
   * Linux: `apt install gfortran`
   * Mac: `brew install gcc`
   * [Windows](https://www.scivision.co/windows-gcc-gfortran-cmake-make-install/)
2. Install Python Lowtran code
   ```sh
   pip install -e .
   ```

### Windows
If you get ImportError on Windows for the Fortran module, try from the `lowtran` directory:
```posh
del *.pyd
python setup.py build_ext --inplace --compiler=mingw32
```

## Examples

In these examples, you can write to HDF5 with the `-o` option. 

We present examples of:

* ground-to-space transmittance: `TransmittanceGround2Space.py`

  ![Lowtran Transmission](doc/txgnd2space.png)
* sun-to-observer scattered radiance (why the sky is blue): `ScatterRadiance.py`

  ![Lowtran Scatter Radiance](gfx/whyskyisblue.png)
* sun-to-observer irradiance: `SolarIrradiance.py`

  ![Lowtran Solar Irradiance](gfx/irradiance.png)
* observer-to-observer solar single-scattering solar radiance (up-going) with custom Pressure, Temperature and partial pressure for 12 species: `UserDataHorizontalRadiance.py`
  ![Lowtran Solar Irradiance](gfx/thermalradiance.png)
* observer-to-observer transmittance with custom Pressure, Temperature and partial pressure for 12 species:  `UserDataHorizontalTransmittance.py`
* observer-to-observer transmittance `HorizontalTransmittance.py`

  ![Lowtran Horizontal Path transmittance](gfx/horizcompare.png)

### Matlab
Matlab &ge; R2014b can seamlessly access Python modules, as demonstrated in `lowtran.m`.

## Notes

LOWTRAN7 [User manual](http://www.dtic.mil/dtic/tr/fulltext/u2/a206773.pdf) -- you may refer to this to understand what parameters are set to default.
Currently I don't have any aerosols enabled for example, though it's straightforward to add them.

Right now a lot of configuration features aren't implemented, please request those you want.

### Reference

* Original 1994 Lowtran7 [Code](http://www1.ncdc.noaa.gov/pub/data/software/lowtran/)
* `LOWFIL` program in reference/lowtran7.10.f was not connected as we had previously implemented a filter function directly in  Python.
* `LOWSCAN` spectral sampling (scanning) program in `reference/lowtran7.13.f` was not connected as we had no need for coarser spectral resolution.

### Fortran (optional)

This is not necessary for normal users:
```sh
cd bin
cmake ..
cmake --build .
ctest -V
```

should generate 
[this text output](https://gist.github.com/drhirsch/89ef2060d8f15b0a60914d13a61e33ab).

