{
  rm(list=ls()); options(error = NULL)
  package_name <- "causalimages"
  setwd(sprintf("~/Desktop/%s-software-aidevlab", package_name))
  
  package_path <- sprintf("~/Desktop/%s-software-aidevlab/%s",package_name,package_name)
  tools::add_datalist(package_path, force = TRUE)
  devtools::document(package_path)
  try(file.remove(sprintf("./%s.pdf",package_name)),T)
  system(sprintf("R CMD Rd2pdf %s",package_path))
  
  # install.packages( sprintf("~/Desktop/%s-software/%s",package_name,package_name),repos = NULL, type = "source")
  # library( causalimages ); data(  CausalImagesTutorialData )
  log(sort( sapply(ls(),function(l_){   object.size(eval(parse(text=l_)))  })))
  
  # Check package to ensure it meets CRAN standards.
  # devtools::check( package_path )
  
  # see https://github.com/RConsortium/S7
}

