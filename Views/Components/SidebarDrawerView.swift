import SwiftUI

/// Sidebar Drawer navigasi samping yang menampilkan info profil pengguna, menu pengaturan, kualitas audio, dan logout
public struct SidebarDrawerView: View {
    @Binding var isPresented: Bool
    @State private var showSettingsModal: Bool = false

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            if isPresented {
                // Backdrop gelap transparan
                Color.black.opacity(0.65)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)

                // Drawer Content Card di Sisi Kiri
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header Profil Pengguna
                        HStack(spacing: 14) {
                            AsyncImage(url: UserProfile.sample.avatarURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    Image(systemName: "person.crop.circle.fill")
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.2), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(UserProfile.sample.name)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)

                                Text("Mode Akun Pro")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(hex: "10B981"))
                                    .lineLimit(1)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "94A3B8"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 54)
                        .padding(.bottom, 20)

                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        // Daftar Menu Navigasi
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 4) {
                                drawerMenuItem(
                                    icon: "person.circle",
                                    iconColor: Color(hex: "10B981"),
                                    title: "Profil Akun"
                                )

                                drawerMenuItem(
                                    icon: "gearshape",
                                    iconColor: Color(hex: "94A3B8"),
                                    title: "Pengaturan"
                                )

                                // Menu Kualitas Audio dengan Tag Chip
                                HStack(spacing: 14) {
                                    Image(systemName: "waveform")
                                        .font(.system(size: 18))
                                        .foregroundColor(Color(hex: "94A3B8"))
                                        .frame(width: 24)

                                    Text("Kualitas Audio")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(Color(hex: "E2E8F0"))

                                    Spacer()

                                    Text("24-bit Hi-Res")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(Color(hex: "10B981"))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Capsule().fill(Color(hex: "10B981").opacity(0.15)))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)

                                drawerMenuItem(
                                    icon: "slider.horizontal.3",
                                    iconColor: Color(hex: "94A3B8"),
                                    title: "Equalizer & Efek"
                                )

                                drawerMenuItem(
                                    icon: "arrow.down.circle",
                                    iconColor: Color(hex: "94A3B8"),
                                    title: "Lagu Terunduh"
                                )
                            }
                        }

                        Spacer()

                        // Tombol Keluar Akun di Bagian Bawah
                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.horizontal, 20)

                        Button {
                            withAnimation {
                                isPresented = false
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "EF4444"))

                                Text("Keluar Akun")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(Color(hex: "EF4444"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.78)
                    .background(Color(hex: "121721"))
                    .overlay(alignment: .trailing) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 1)
                    }
                    .ignoresSafeArea(.all, edges: .vertical)

                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
        }
    }

    @ViewBuilder
    private func drawerMenuItem(icon: String, iconColor: Color, title: String) -> some View {
        Button {
            withAnimation {
                isPresented = false
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "E2E8F0"))

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
