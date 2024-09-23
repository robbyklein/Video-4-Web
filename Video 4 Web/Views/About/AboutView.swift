import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Spacer().frame(height: 10)

            Image("Icon")
                .resizable()
                .frame(width: 80, height: 80)

            Spacer().frame(height: 10)

            Text("Video 4 Web")
                .font(.headline)
                .foregroundColor(.primary)

            Spacer().frame(height: 5)

            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                Text("Version \(version)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer().frame(height: 20)

            Text(
                """
                [Video 4 Web](https://video4web.robbyk.com) by [Robert Klein](https://robbyk.com) \
                is a GUI for [FFmpeg](https://www.ffmpeg.org/) and was inspired by \
                [ImageOptim](https://imageoptim.com/).

                Video 4 Web can be redistributed and modified under \
                [GNU General Public License version 2](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html) or later.
                """
            )
                .font(.body)
                .multilineTextAlignment(.center)

            Spacer()
        }.padding()
    }
}
