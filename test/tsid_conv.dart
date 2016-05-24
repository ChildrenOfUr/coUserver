import "package:coUserver/common/util.dart";
import "package:test/test.dart";

void main() {
	group("TSID Conversions", () {
		final String cebarkulG = "GIF12PMQ5121D68";
		final String cebarkulL = "LIF12PMQ5121D68";

		final String chavilaG = "GHVLG51LV6B22AO";
		final String chavilaL = "LHVLG51LV6B22AO";

		test("G to L", () {
			expect(tsidL(cebarkulG), cebarkulL);
			expect(tsidL(chavilaL), chavilaL);
		});

		test("L to G", () {
			expect(tsidG(cebarkulL), cebarkulG);
			expect(tsidG(chavilaL), chavilaG);
		});

		test("G to G", () {
			expect(tsidG(cebarkulG), cebarkulG);
			expect(tsidG(chavilaG), chavilaG);
		});

		test("L to L", () {
			expect(tsidL(cebarkulL), cebarkulL);
			expect(tsidL(chavilaL), chavilaL);
		});
	});
}