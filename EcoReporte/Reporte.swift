//
//  Reporte.swift
//  EcoReporte
//
//  Modelo del reporte y funciones para guardar los datos en el teléfono.
//

import SwiftUI

// Opciones fijas que se usan en los Picker
let categorias = ["Basura", "Agua", "Áreas verdes", "Contaminación", "Energía", "Otro"]
let estados = ["Pendiente", "En proceso", "Resuelto"]

// Datos de un reporte
struct Reporte: Identifiable, Codable, Equatable {
    var id = UUID()
    var titulo: String
    var categoria: String
    var descripcion: String
    var ubicacion: String
    var estado: String
    var nombreFoto: String   // nombre del archivo de la foto guardada
    var fecha: Date
}

// MARK: - Guardado local

// Carpeta Documents de la app
func carpetaDocumentos() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

// Archivo JSON donde se guarda la lista de reportes
func rutaArchivoReportes() -> URL {
    return carpetaDocumentos().appendingPathComponent("reportes.json")
}

// Guarda toda la lista de reportes en el archivo JSON
func guardarReportes(_ reportes: [Reporte]) {
    do {
        let datos = try JSONEncoder().encode(reportes)
        try datos.write(to: rutaArchivoReportes(), options: .atomic)
    } catch {
        print("Error al guardar los reportes: \(error)")
    }
}

// Lee la lista de reportes del archivo JSON
func cargarReportes() -> [Reporte] {
    do {
        let datos = try Data(contentsOf: rutaArchivoReportes())
        return try JSONDecoder().decode([Reporte].self, from: datos)
    } catch {
        // La primera vez el archivo todavía no existe
        return []
    }
}

// Guarda la foto como archivo .jpg y regresa su nombre
func guardarImagen(_ imagen: UIImage) -> String? {
    guard let datos = imagen.jpegData(compressionQuality: 0.8) else {
        return nil
    }
    let nombre = UUID().uuidString + ".jpg"
    let ruta = carpetaDocumentos().appendingPathComponent(nombre)
    do {
        try datos.write(to: ruta)
        return nombre
    } catch {
        return nil
    }
}

// Lee una foto guardada usando su nombre
func cargarImagenGuardada(nombre: String) -> UIImage? {
    let ruta = carpetaDocumentos().appendingPathComponent(nombre)
    return UIImage(contentsOfFile: ruta.path)
}

// Borra el archivo de una foto
func borrarImagen(nombre: String) {
    let ruta = carpetaDocumentos().appendingPathComponent(nombre)
    try? FileManager.default.removeItem(at: ruta)
}
