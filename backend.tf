terraform {
  backend "remote" {
    organization = "wineperm-diplom-netology"
    workspaces {
      name = "wineperm-dip"
    }
  }
}
