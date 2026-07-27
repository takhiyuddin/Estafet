//
//  ContentView.swift
//  Continuum
//
//  Created by Takhiyuddin on 27/07/26.
//

import SwiftUI
import Combine

// MARK: - 1. MODEL DATA
struct HandoverLog: Identifiable {
    let id = UUID()
    let unitName: String
    let condition: MachineCondition
    let outgoingOperator: String
    let incomingOperator: String?
    let notes: String
    let timestamp: Date
    var isAcknowledged: Bool
}

enum MachineCondition: String, CaseIterable {
    case normal = "Normal (Aman)"
    case warning = "Perlu Perhatian"
    case breakdown = "Rusak (Breakdown)"
    
    var color: Color {
        switch self {
        case .normal: return .green
        case .warning: return .orange
        case .breakdown: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .breakdown: return "xmark.octagon.fill"
        }
    }
}

// MARK: - 2. VIEW MODEL (STATE MANAGEMENT)
class EstafetViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUserID: String = ""
    @Published var currentUserName: String = ""
    @Published var isSupervisor: Bool = false
    
    // Data Dummy Handover Log
    @Published var handovers: [HandoverLog] = [
        HandoverLog(unitName: "Excavator EX-200", condition: .normal, outgoingOperator: "Budi (Shift Siang)", incomingOperator: "Joko", notes: "Semua sistem hidrolik normal. Bahan bakar tersisa 60%.", timestamp: Date().addingTimeInterval(-3600), isAcknowledged: true),
        HandoverLog(unitName: "Rig Pump #3", condition: .warning, outgoingOperator: "Rian (Shift Malam)", incomingOperator: nil, notes: "Tekanan pompa agak turun di jam 3 pagi. Suhu mesin naik sedikit. Mohon dipantau ketat.", timestamp: Date().addingTimeInterval(-1800), isAcknowledged: false),
        HandoverLog(unitName: "Conveyor Belt A", condition: .breakdown, outgoingOperator: "Agus (Shift Siang)", incomingOperator: "Herman", notes: "Belt sobek di sektor 4. Sedang ditangani tim mekanik. Jangan dinyalakan!", timestamp: Date().addingTimeInterval(-86400), isAcknowledged: true)
    ]
    
    func login(id: String, name: String) {
        self.currentUserID = id.uppercased()
        self.currentUserName = name.trimmingCharacters(in: .whitespaces).isEmpty ? "User \(id)" : name
        
        // Cek Role: SPV = Supervisor, lainnya = Operator
        self.isSupervisor = self.currentUserID.hasPrefix("SPV")
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isLoggedIn = false
            self.currentUserID = ""
            self.currentUserName = ""
            self.isSupervisor = false
        }
    }
    
    func submitHandover(unit: String, condition: MachineCondition, notes: String) {
        let newLog = HandoverLog(unitName: unit, condition: condition, outgoingOperator: currentUserName, incomingOperator: nil, notes: notes, timestamp: Date(), isAcknowledged: false)
        withAnimation {
            handovers.insert(newLog, at: 0)
        }
    }
    
    func acknowledgeHandover(logID: UUID) {
        if let index = handovers.firstIndex(where: { $0.id == logID }) {
            withAnimation {
                handovers[index].isAcknowledged = true
                // Dalam aplikasi nyata, property incomingOperator juga akan diupdate dengan nama user saat ini
            }
        }
    }
}

// MARK: - 3. ROOT VIEW (ROUTER)
struct ContentView: View {
    @StateObject var viewModel = EstafetViewModel()
    
    var body: some View {
        ZStack {
            if !viewModel.isLoggedIn {
                LoginView()
                    .environmentObject(viewModel)
                    .transition(.asymmetric(insertion: .opacity, removal: .scale(scale: 0.95).combined(with: .opacity)))
            } else {
                if viewModel.isSupervisor {
                    SupervisorDashboardView()
                        .environmentObject(viewModel)
                        .transition(.opacity)
                } else {
                    OperatorPortalView()
                        .environmentObject(viewModel)
                        .transition(.opacity)
                }
            }
        }
        .environment(\.colorScheme, .light)
    }
}

// MARK: - 4. HALAMAN LOGIN
struct LoginView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    @State private var idInput = ""
    @State private var nameInput = ""
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            // Background Ornamen
            Circle().fill(Color.orange.opacity(0.15)).frame(width: 300).blur(radius: 50).offset(x: 150, y: -200)
            Circle().fill(Color.blue.opacity(0.1)).frame(width: 400).blur(radius: 60).offset(x: -150, y: 300)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text("Estafet")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Digital Shift Handover System")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 80)
                    
                    VStack(spacing: 20) {
                        CustomTextField(icon: "person.fill", placeholder: "Nama Lengkap", text: $nameInput)
                        CustomTextField(icon: "lanyardcard.fill", placeholder: "ID Pekerja (Cth: OP-12 atau SPV-01)", text: $idInput)
                    }
                    .padding(.top, 20)
                    
                    Button(action: {
                        if !idInput.isEmpty { viewModel.login(id: idInput, name: nameInput) }
                    }) {
                        Text("Masuk & Mulai Giliran")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(idInput.isEmpty ? Color.gray.opacity(0.5) : Color.orange)
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(idInput.isEmpty ? 0 : 0.4), radius: 10, x: 0, y: 5)
                    }
                    .disabled(idInput.isEmpty)
                    .padding(.top, 10)
                    
                    HStack {
                        Image(systemName: "info.circle.fill").foregroundColor(.orange)
                        Text("Login dengan ID awalan 'SPV' untuk akses Mandor/Supervisor. Awalan lain untuk Operator.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(16).background(Color.orange.opacity(0.1)).cornerRadius(12).padding(.top, 20)
                }
                .padding(32)
            }
        }
    }
}

struct CustomTextField: View {
    var icon: String; var placeholder: String; @Binding var text: String
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).foregroundColor(.secondary).frame(width: 24)
            TextField(placeholder, text: $text).autocapitalization(.none)
        }
        .padding(.horizontal, 20).frame(height: 56).background(Color.white).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - 5. PORTAL OPERATOR (MOBILE APP)
struct OperatorPortalView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { OperatorHomeView() }
                .tabItem { Label("Beranda", systemImage: "house.fill") }.tag(0)
            
            NavigationStack { SubmitHandoverView() }
                .tabItem { Label("Buat Laporan", systemImage: "doc.badge.plus") }.tag(1)
            
            NavigationStack { ProfileSettingsView() }
                .tabItem { Label("Profil", systemImage: "person.fill") }.tag(2)
        }
        .tint(.orange)
    }
}

struct OperatorHomeView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    
    // Cari handover yang belum di-acknowledge (Menunggu penerima)
    var pendingHandovers: [HandoverLog] {
        viewModel.handovers.filter { !$0.isAcknowledged }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Giliran Aktif (Shift)").font(.system(size: 13, weight: .bold)).foregroundColor(.orange).tracking(1.0)
                            Text("Halo, \(viewModel.currentUserName)").font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(Color.orange.opacity(0.2)).frame(width: 44, height: 44)
                            Text(String(viewModel.currentUserName.prefix(1)).uppercased()).font(.system(size: 18, weight: .bold)).foregroundColor(.orange)
                        }
                    }
                    .padding(24).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                    // Notifikasi Serah Terima Tertunda (Urgent Action Required)
                    if !pendingHandovers.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "bell.badge.fill").foregroundColor(.red)
                                Text("Tindakan Diperlukan").font(.system(size: 14, weight: .bold)).foregroundColor(.red)
                            }
                            Text("Ada laporan serah terima mesin yang belum Anda setujui. Mohon baca kondisi mesin sebelum memulai kerja.")
                                .font(.system(size: 13)).foregroundColor(.primary).lineSpacing(4)
                            
                            ForEach(pendingHandovers) { log in
                                AcknowledgeCard(log: log)
                            }
                        }
                        .padding(20).background(Color.red.opacity(0.08)).cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    } else {
                        // Status Aman
                        HStack(spacing: 16) {
                            Image(systemName: "checkmark.shield.fill").font(.system(size: 30)).foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Semua Selesai").font(.system(size: 16, weight: .bold))
                                Text("Tidak ada serah terima yang tertunda.").font(.system(size: 13)).foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(20).background(Color.green.opacity(0.1)).cornerRadius(20)
                    }
                    
                    // Riwayat Serah Terima
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Riwayat Mesin Terkini").font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.handovers.filter { $0.isAcknowledged }) { log in
                                HandoverHistoryCard(log: log)
                            }
                        }
                    }
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
            .navigationTitle("Beranda Operator")
            .navigationBarHidden(true)
        }
    }
}

// Kartu Untuk Menyetujui Handover
struct AcknowledgeCard: View {
    var log: HandoverLog
    @EnvironmentObject var viewModel: EstafetViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.unitName).font(.system(size: 16, weight: .bold))
                Spacer()
                MachineBadge(condition: log.condition)
            }
            Divider()
            VStack(alignment: .leading, spacing: 4) {
                Text("Operator Sebelumnya: \(log.outgoingOperator)").font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
                Text(log.notes).font(.system(size: 14)).foregroundColor(.primary).italic().padding(.top, 4)
            }
            Button(action: {
                viewModel.acknowledgeHandover(logID: log.id)
            }) {
                HStack {
                    Image(systemName: "signature")
                    Text("Terima & Mulai Giliran")
                }
                .font(.system(size: 14, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 44)
                .background(Color.blue).cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// Kartu Riwayat
struct HandoverHistoryCard: View {
    var log: HandoverLog
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(log.unitName).font(.system(size: 16, weight: .bold))
                Spacer()
                MachineBadge(condition: log.condition)
            }
            Divider()
            Text(log.notes).font(.system(size: 14)).foregroundColor(.secondary)
            HStack {
                Image(systemName: "arrow.turn.down.right").foregroundColor(.gray)
                Text("\(log.outgoingOperator) → \(log.incomingOperator ?? "Operator Baru")")
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.gray)
                Spacer()
                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            }
        }
        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// Form Buat Handover Baru
struct SubmitHandoverView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    @State private var selectedUnit = "Excavator EX-200"
    @State private var selectedCondition: MachineCondition = .normal
    @State private var notes = ""
    @State private var showingAlert = false
    
    let units = ["Excavator EX-200", "Dump Truck DT-05", "Rig Pump #3", "Conveyor Belt A"]
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Akhiri Giliran Kerja").font(.system(size: 24, weight: .bold, design: .rounded))
                        Text("Laporkan kondisi mesin aktual sebelum Anda meninggalkan area kerja.").font(.system(size: 14)).foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pilih Unit / Mesin").font(.system(size: 14, weight: .bold))
                            Picker("Unit", selection: $selectedUnit) { ForEach(units, id: \.self) { Text($0) } }
                            .frame(height: 50).frame(maxWidth: .infinity).background(Color(UIColor.systemGray6)).cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status Kondisi Akhir").font(.system(size: 14, weight: .bold))
                            HStack(spacing: 10) {
                                ForEach(MachineCondition.allCases, id: \.self) { condition in
                                    Button(action: { selectedCondition = condition }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: condition.icon).font(.system(size: 24))
                                            Text(condition.rawValue).font(.system(size: 10, weight: .bold)).multilineTextAlignment(.center)
                                        }
                                        .foregroundColor(selectedCondition == condition ? .white : condition.color)
                                        .frame(maxWidth: .infinity).frame(height: 80)
                                        .background(selectedCondition == condition ? condition.color : condition.color.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Catatan / PR untuk Shift Selanjutnya").font(.system(size: 14, weight: .bold))
                            TextEditor(text: $notes)
                                .frame(height: 120).padding(8)
                                .background(Color(UIColor.systemGray6)).cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .padding(20).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
                    
                    Button(action: {
                        viewModel.submitHandover(unit: selectedUnit, condition: selectedCondition, notes: notes)
                        notes = ""
                        showingAlert = true
                    }) {
                        Text("Kirim Laporan & Selesai Shift")
                            .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 56).background(Color.orange).cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 10)
                }
                .padding(24)
            }
            .navigationTitle("Buat Laporan")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Berhasil"), message: Text("Laporan serah terima telah masuk ke sistem. Anda dapat beristirahat sekarang."), dismissButton: .default(Text("Tutup")))
            }
        }
    }
}

// MARK: - 6. DASHBOARD SUPERVISOR / MANDOR
struct SupervisorDashboardView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    
    var body: some View {
        TabView {
            NavigationStack { SpvOverviewView() }
                .tabItem { Label("Overview", systemImage: "chart.bar.doc.horizontal.fill") }
            
            NavigationStack { ProfileSettingsView() }
                .tabItem { Label("Profil", systemImage: "person.crop.circle.fill") }
        }
        .tint(.blue)
    }
}

struct SpvOverviewView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    
    var issueCount: Int {
        viewModel.handovers.filter { $0.condition == .breakdown || $0.condition == .warning }.count
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Mandor
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("DASHBOARD MANDOR").font(.system(size: 11, weight: .bold)).foregroundColor(.blue).tracking(1.0)
                            Text("Ringkasan Operasional").font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Image(systemName: "shield.checkmark.fill").font(.system(size: 30)).foregroundColor(.blue)
                    }
                    .padding(24).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    
                    // KPI Cards
                    HStack(spacing: 16) {
                        SpvKpiCard(title: "Mesin Bermasalah", value: "\(issueCount)", icon: "exclamationmark.triangle.fill", color: .red)
                        SpvKpiCard(title: "Log Menunggu", value: "\(viewModel.handovers.filter({!$0.isAcknowledged}).count)", icon: "clock.fill", color: .orange)
                    }
                    
                    // Log Laporan Keseluruhan
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Live Log Serah Terima").font(.system(size: 18, weight: .bold, design: .rounded))
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.handovers) { log in
                                SpvHandoverCard(log: log)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Command Center")
            .navigationBarHidden(true)
        }
    }
}

struct SpvKpiCard: View {
    var title: String; var value: String; var icon: String; var color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon).font(.system(size: 24)).foregroundColor(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(value).font(.system(size: 32, weight: .bold, design: .rounded))
                Text(title).font(.system(size: 12, weight: .medium)).foregroundColor(.secondary)
            }
        }
        .padding(20).frame(maxWidth: .infinity, alignment: .leading).background(Color.white).cornerRadius(20).shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct SpvHandoverCard: View {
    var log: HandoverLog
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MachineBadge(condition: log.condition)
                Spacer()
                if log.isAcknowledged {
                    Text("Telah Dibaca").font(.system(size: 10, weight: .bold)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.green.opacity(0.1)).foregroundColor(.green).cornerRadius(8)
                } else {
                    Text("Menunggu").font(.system(size: 10, weight: .bold)).padding(.horizontal, 8).padding(.vertical, 4).background(Color.orange.opacity(0.1)).foregroundColor(.orange).cornerRadius(8)
                }
            }
            Text(log.unitName).font(.system(size: 16, weight: .bold))
            Text(log.notes).font(.system(size: 13)).foregroundColor(.secondary).lineLimit(2)
            Divider().padding(.vertical, 4)
            HStack {
                Text(log.outgoingOperator).font(.system(size: 11, weight: .bold))
                Image(systemName: "arrow.right").font(.system(size: 10)).foregroundColor(.gray)
                Text(log.incomingOperator ?? "Belum ada").font(.system(size: 11, weight: .medium)).foregroundColor(log.incomingOperator == nil ? .gray : .primary)
            }
        }
        .padding(16).background(Color.white).cornerRadius(16).shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(log.condition == .breakdown ? Color.red.opacity(0.5) : Color.clear, lineWidth: 2))
    }
}

// MARK: - 7. KOMPONEN UMUM
struct MachineBadge: View {
    var condition: MachineCondition
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: condition.icon)
            Text(condition.rawValue)
        }
        .font(.system(size: 10, weight: .bold)).foregroundColor(condition.color)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(condition.color.opacity(0.1)).clipShape(Capsule())
    }
}

struct ProfileSettingsView: View {
    @EnvironmentObject var viewModel: EstafetViewModel
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.orange.opacity(0.2)).frame(width: 80, height: 80)
                        Image(systemName: "person.fill").font(.system(size: 40)).foregroundColor(.orange)
                    }
                    Text(viewModel.currentUserName).font(.system(size: 22, weight: .bold, design: .rounded))
                    Text(viewModel.isSupervisor ? "Supervisor (Mandor)" : "Operator / Mekanik").font(.system(size: 14)).foregroundColor(.secondary)
                    Text("ID: \(viewModel.currentUserID)").font(.system(size: 12, weight: .bold)).padding(.horizontal, 10).padding(.vertical, 4).background(Color.gray.opacity(0.2)).cornerRadius(8)
                }
                .padding(24).frame(maxWidth: .infinity).background(Color.white).cornerRadius(20)
                
                Button(action: { viewModel.logout() }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                        Text("Keluar (Logout)")
                    }
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.red)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(Color.white).cornerRadius(16)
                }
                Spacer()
            }
            .padding(24)
        }
        .navigationTitle("Pengaturan Akun")
        .navigationBarTitleDisplayMode(.inline)
    }
}
