
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pipfaker

<!-- badges: start -->
<!-- badges: end -->

The goal of this package is to provide users who would like to use (or
generate) *fake* [PIP](https://pip.worldbank.org/) data in several
formats (raw or cache) and distribution types (micro, group, bin or
imputed).

## Installation

You can install the development version of pipfaker from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("PIP-Technical-Team/pipfaker")
```

## Example

This is a basic example which shows you how to use a fake PIP data set:

``` r
library(pipfaker)
## basic example code

micro_cache_pip <- fk_cache_micro

mean_welf <- mean(micro_cache_pip$welfare_ppp, w = micro_cache_pip$weight)
mean_welf
#> [1] 167.9859
```

## For `pipapi`

This package can be used to create fake data to test `pipapi`. You can
provide an `input_path` to a reference folder you want to mimic. If
`input_path` is not provided the `fk_pip` functions uses the fake data
already installed within this package. The following example will save
the new fake data into your working directory (`output_path`).

``` r

## basic example code for pipapi using input_path

# fk_pip(output_path = ".", input_path =  "E:/PIP/pipapi_data/20240627_2017_01_02_PROD")

## without input_path (using fake data)

# fk_pip(output_path = ".")
```
