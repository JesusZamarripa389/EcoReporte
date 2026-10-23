//
//  DetalleReporteView.swift
//  EcoReporte
//
//  Muestra la información de un reporte y permite cambiar su estado.
//

import SwiftUI

struct DetalleReporteView: View {

    // Reporte que se está viendo (los cambios regresan a la lista)
    @Binding var reporte: Reporte

    var body: some View {
        Form {
            Section("Fotografía") {
                if let imagen = cargarImagenGuardada(nombre: reporte.nombreFoto) {
                    Image(uiImage: imagen)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("No se encontró la fotografía")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Información") {
                LabeledContent("Título", value: reporte.titulo)
                LabeledContent("Categoría", value: reporte.categoria)
                LabeledContent("Ubicación", value: reporte.ubicacion)
                LabeledContent("Fecha", value: reporte.fecha.formatted(date: .abbreviated, time: .shortened))
            }

            Section("Descripción") {
                Text(reporte.descripcion)
            }

            // Cambiar el estado del reporte
            Section("Estado") {
                Picker("Estado", selection: $reporte.estado) {
                    ForEach(estados, id: \.self) { estado in
                        Text(estado).tag(estado)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
