//
//  ContentView.swift
//  EcoReporte
//
//  Pantalla principal: resumen, filtros y lista de reportes.
//

import SwiftUI

struct ContentView: View {

    // Lista de reportes (se carga del archivo al abrir la app)
    @State private var reportes: [Reporte] = cargarReportes()

    // Filtros seleccionados
    @State private var filtroCategoria = "Todas"
    @State private var filtroEstado = "Todos"

    // Mostrar el formulario de nuevo reporte
    @State private var mostrarFormulario = false

    // Reporte que se quiere eliminar y alerta de confirmación
    @State private var reporteAEliminar: Reporte?
    @State private var mostrarConfirmacion = false

    var body: some View {
        NavigationStack {
            List {
                // Resumen de reportes por estado
                Section("Resumen") {
                    ForEach(estados, id: \.self) { estado in
                        HStack {
                            Text(estado)
                            Spacer()
                            Text("\(contarReportes(estado: estado))")
                                .bold()
                        }
                    }
                }

                // Filtros
                Section("Filtros") {
                    Picker("Categoría", selection: $filtroCategoria) {
                        Text("Todas").tag("Todas")
                        ForEach(categorias, id: \.self) { categoria in
                            Text(categoria).tag(categoria)
                        }
                    }
                    Picker("Estado", selection: $filtroEstado) {
                        Text("Todos").tag("Todos")
                        ForEach(estados, id: \.self) { estado in
                            Text(estado).tag(estado)
                        }
                    }
                }

                // Lista de reportes
                Section("Reportes") {
                    if cantidadFiltrada() == 0 {
                        Text("No hay reportes para mostrar")
                            .foregroundStyle(.secondary)
                    }

                    ForEach($reportes) { $reporte in
                        if cumpleFiltros(reporte) {
                            NavigationLink {
                                DetalleReporteView(reporte: $reporte)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reporte.titulo)
                                        .font(.headline)
                                    Text("\(reporte.categoria) · \(reporte.estado)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            // Deslizar a la izquierda para eliminar
                            .swipeActions {
                                Button {
                                    reporteAEliminar = reporte
                                    mostrarConfirmacion = true
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("EcoReporte")
            .toolbar {
                Button {
                    mostrarFormulario = true
                } label: {
                    Label("Nuevo reporte", systemImage: "plus")
                }
            }
            .sheet(isPresented: $mostrarFormulario) {
                NuevoReporteView(reportes: $reportes)
            }
            .alert("¿Eliminar reporte?", isPresented: $mostrarConfirmacion) {
                Button("Eliminar", role: .destructive) {
                    eliminarReporte()
                }
                Button("Cancelar", role: .cancel) {
                    reporteAEliminar = nil
                }
            } message: {
                Text("Esta acción no se puede deshacer.")
            }
            // Cada vez que cambia la lista se guarda en el archivo
            .onChange(of: reportes) {
                guardarReportes(reportes)
            }
        }
    }

    // Revisa si un reporte coincide con los filtros elegidos
    private func cumpleFiltros(_ reporte: Reporte) -> Bool {
        let categoriaCorrecta = filtroCategoria == "Todas" || reporte.categoria == filtroCategoria
        let estadoCorrecto = filtroEstado == "Todos" || reporte.estado == filtroEstado
        return categoriaCorrecta && estadoCorrecto
    }

    // Cantidad de reportes que se ven con los filtros
    private func cantidadFiltrada() -> Int {
        return reportes.filter { cumpleFiltros($0) }.count
    }

    // Cantidad de reportes con cierto estado
    private func contarReportes(estado: String) -> Int {
        return reportes.filter { $0.estado == estado }.count
    }

    // Elimina el reporte elegido y su foto
    private func eliminarReporte() {
        if let reporte = reporteAEliminar {
            borrarImagen(nombre: reporte.nombreFoto)
            reportes.removeAll { $0.id == reporte.id }
        }
        reporteAEliminar = nil
    }
}

#Preview {
    ContentView()
}
