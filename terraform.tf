resource "local_file" "productos" {
    content = "Lista de productos modificada"
    filename = "productos.txt"
}