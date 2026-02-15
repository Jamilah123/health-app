import AppIntents

struct AddInsulinIntent: AppIntent {

    static var title: LocalizedStringResource = "تسجيل جرعة إنسولين"
    static var description = IntentDescription("تسجيل جرعة إنسولين بالصوت")

    @Parameter(title: "عدد الوحدات")
    var units: Int

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {

        // حفظ الجرعة في RecordsStore مباشرة
        RecordsStore.shared.addInsulin(units: units)

        return .result(dialog: "تم تسجيل \(units) وحدات إنسولين بنجاح")
    }
}

