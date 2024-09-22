import SwiftUI

struct FilesListView: View {
    @EnvironmentObject var viewModel: ContentViewModel // Use EnvironmentObject

    var body: some View {
        Table(viewModel.fileStatuses) {
            TableColumn("") { fileStatus in
                StatusCell(fileStatus: fileStatus)
            }
            .width(30) // Adjusted width for the icon

            TableColumn("Name") { fileStatus in
                NameCell(fileStatus: fileStatus)
            }
            .width(min: 100, ideal: 10, max: .infinity)

            TableColumn("Original Size") { fileStatus in
                OriginalSizeCell(fileStatus: fileStatus)
            }
            .width(80)

            TableColumn("New Size") { fileStatus in
                NewSizeCell(fileStatus: fileStatus)
            }
            .width(80)

            TableColumn("Savings") { fileStatus in
                SavingsCell(fileStatus: fileStatus)
            }
            .width(80)

            TableColumn("") { fileStatus in
                ActionCell(fileStatus: fileStatus)
            }
            .width(30)
        }
        .tableStyle(.inset(alternatesRowBackgrounds: true))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(\.defaultMinListRowHeight, 30) // Set minimum row height
    }
}

struct StatusCell: View {
    @ObservedObject var fileStatus: FileStatus

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 20)

            Group {
                switch fileStatus.status {
                case "Completed":
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                case "Processing":
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.55)
                        .frame(width: 16, height: 16)
                case "Queued":
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                default:
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                        .font(.system(size: 16))
                        .frame(width: 16, height: 16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct NameCell: View {
    let fileStatus: FileStatus

    var body: some View {
        Text(fileStatus.fileName)
            .lineLimit(1)
            .truncationMode(.middle)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct OriginalSizeCell: View {
    @ObservedObject var fileStatus: FileStatus

    var body: some View {
        Text(fileStatus.originalSizeFormatted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct NewSizeCell: View {
    @ObservedObject var fileStatus: FileStatus

    var body: some View {
        Text(fileStatus.newSizeFormatted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SavingsCell: View {
    @ObservedObject var fileStatus: FileStatus

    var body: some View {
        Text(fileStatus.savingsFormatted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ActionCell: View {
    @ObservedObject var fileStatus: FileStatus
    @EnvironmentObject var viewModel: ContentViewModel

    var body: some View {
        if fileStatus.status == "Processing" || fileStatus.status == "Queued" {
            Button(action: {
                viewModel.cancelOperation(for: fileStatus)
            }, label: {
                Image(systemName: "stop.circle.fill")
                    .foregroundColor(.secondary)
            })
            .buttonStyle(BorderlessButtonStyle())
        } else {
            EmptyView()
        }
    }
}
