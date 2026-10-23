//
//  NuevoReporteView.swift
//  EcoReporte
//
//  Formulario para registrar un reporte nuevo.
//

import SwiftUI
import PhotosUI

struct NuevoReporteView: View {

    // Lista de reportes de la pantalla principal
    @Binding var reportes: [Reporte]

    // Para cerrar esta pantalla
    @Environment(\.dismiss) private var dismiss

    // Campos del formulario
    @State private var titulo = ""
    @State private var categoria = ""
    @State private var descripcion = ""
    @State private var ubicacion = ""

    // Fotografía seleccionada y su imagen
    @State private var fotoSeleccionada: PhotosPickerItem?
    @State private var imagen: UIImage?
    @State private var cargando = false

    // Mensaje cuando faltan datos o hay un error
    @State private var mensajeError = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del reporte") {
                    TextField("Título", text: $titulo)

                    Picker("Categoría", selection: $categoria) {
                        Text("Selecciona").tag("")
                        ForEach(categorias, id: \.self) { categoria in
                            Text(categoria).tag(categoria)
                        }
                    }

                    TextField("Descripción", text: $descripcion, axis: .vertical)
                        .lineLimit(3...6)

                    TextField("Ubicación (ej. Edificio A)", text: $ubicacion)
                }

                Section("Fotografía") {
                    // Vista previa de la foto
                    if let imagen = imagen {
                        Image(uiImage: imagen)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("No has seleccionado una foto")
                            .foregroundStyle(.secondary)
                    }

                    if cargando {
                        ProgressView("Cargando fotografía...")
                    }

                    // Selector de fotografía
                    PhotosPicker(selection: $fotoSeleccionada, matching: .images) {
                        Label(
                            imagen == nil ? "Seleccionar foto" : "Cambiar foto",
                            systemImage: "photo.on.rectangle"
                        )
                    }
                    .disabled(cargando)
                }

                if !mensajeError.isEmpty {
                    Section {
                        Text(mensajeError)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Guardar reporte") {
                        guardarReporte()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(cargando)
                }
            }
            .navigationTitle("Nuevo reporte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
            .task(id: fotoSeleccionada) {
                guard let seleccion = fotoSeleccionada else {
                    return
                }
                await cargarFoto(desde: seleccion)
            }
        }
    }

    @MainActor
    private func cargarFoto(desde seleccion: PhotosPickerItem) async {
        cargando = true
        mensajeError = ""

        defer {
            cargando = false
        }
        do {
            // Traer los datos de la fotografía seleccionada
            let datos = try await seleccion.loadTransferable(type: Data.self)

            // Las cargas canceladas no se muestran
            try Task.checkCancellation()
            if let datos = datos,
               let nuevaImagen = UIImage(data: datos) {
                imagen = nuevaImagen
            } else {
                mensajeError = "No se pudo cargar la fotografía"
            }
        } catch is CancellationError {
            return
        } catch {
            mensajeError = "No se pudo cargar la fotografía.\nIntenta seleccionar otra imagen"
        }
    }

    // Regresa un mensaje con los campos que faltan (vacío si todo está bien)
    private func validarCampos() -> String {
        var faltantes: [String] = []

        if titulo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            faltantes.append("título")
        }
        if categoria.isEmpty {
            faltantes.append("categoría")
        }
        if descripcion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            faltantes.append("descripción")
        }
        if ubicacion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            faltantes.append("ubicación")
        }
        if imagen == nil {
            faltantes.append("fotografía")
        }

        if faltantes.isEmpty {
            return ""
        }
        return "Completa los siguientes campos: " + faltantes.joined(separator: ", ")
    }

    // Valida, guarda la foto y agrega el reporte a la lista
    private func guardarReporte() {
        mensajeError = validarCampos()
        if !mensajeError.isEmpty {
            return
        }

        // Guardar la foto como archivo y obtener su nombre
        guard let imagen = imagen, let nombreFoto = guardarImagen(imagen) else {
            mensajeError = "No se pudo guardar la fotografía. Intenta de nuevo."
            return
        }

        let nuevoReporte = Reporte(
            titulo: titulo.trimmingCharacters(in: .whitespacesAndNewlines),
            categoria: categoria,
            descripcion: descripcion.trimmingCharacters(in: .whitespacesAndNewlines),
            ubicacion: ubicacion.trimmingCharacters(in: .whitespacesAndNewlines),
            estado: "Pendiente",
            nombreFoto: nombreFoto,
            fecha: Date()
        )

        reportes.append(nuevoReporte)
        dismiss()
    }
}
