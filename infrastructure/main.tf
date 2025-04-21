terraform {
  backend "remote" {
    organization = "northwestwind"
    workspaces {
      name = "SWAPSTAMP"
    }
  }
}
