import AppIntents

struct AddInsulinIntent: AppIntent {

    static var title: LocalizedStringResource = "تسجيل جرعة إنسولين"

    @Parameter(title: "عدد الوحدات")
    var units: Int

    static var openAppWhenRun = false

    func perform() async throws -> some IntentResult {
        RecordsStore.shared.addInsulin(units: units)

        return .result(
            dialog: "تم تسجيل \(units) وحدات"
        )
    }
}
