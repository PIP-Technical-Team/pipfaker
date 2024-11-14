#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Create aux and estimations folders   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dir.create("data/_aux")
dir.create("data/estimations")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load files in gh branch   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

input_path <- "E:/PIP/pipapi_data/20240627_2017_01_02_PROD"

# file_list <- fs::dir_ls(fs::path(input_path,"_aux"))
# fst_files <- file_list[grepl("\\.fst$", file_list)]

# file <- load_files_pip(fst_files[[1]])
#
# usethis::use_data(file,
#                     path = fs::path("data/_aux",basename(fst_files[[1]])),
#                     overwrite = TRUE)

dirs <- list("_aux","estimations") # Make it soft coded

lapply(dirs, copy_dirs,
       input_path = input_path,
       output_path = "data",
       ext = "fst")


