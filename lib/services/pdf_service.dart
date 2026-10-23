import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class PdfService {
  static Future<void> gerarPdfDoMes({
    required Veiculo veiculo,
    required String nomeMes,
    required int ano,
    required List<Abastecimento> abastecimentos,
    required double totalGastoMes,
    required double mediaGastoPorAbastecimento,
    required double mediaKmRodados,
    required double mediaKmPorLitro,
    required String statusConsumoMercado,
  }) async {
    final pdf = pw.Document();
    final tituloPagina =
        'Relatório de Consumo - ${veiculo.placa} (${veiculo.tipo}) - $nomeMes/$ano';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Título da Página no PDF
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    tituloPagina,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Referência de Mercado cadastrada: Gasolina ${veiculo.mediaMercadoGasolina.toStringAsFixed(1)} KM/L | Álcool ${veiculo.mediaMercadoAlcool.toStringAsFixed(1)} KM/L',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Tabela de Abastecimentos editada até o momento
            pw.TableHelper.fromTextArray(
              headers: [
                'Data',
                'Posto',
                'Placa',
                'Tipo',
                'Combustível',
                'KM Ant.',
                'KM Atual',
                'KM Rodados',
                'Litros',
                'R\$/Litro',
                'KM/Litro',
                'Total (R\$)',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8.5),
              cellAlignment: pw.Alignment.center,
              data: abastecimentos.map((a) {
                return [
                  a.data,
                  a.posto,
                  a.placaVeiculo,
                  a.tipoVeiculo,
                  a.tipoCombustivel,
                  a.kmAnterior.toStringAsFixed(1),
                  a.kmAtual.toStringAsFixed(1),
                  a.kmRodados.toStringAsFixed(1),
                  a.litros.toStringAsFixed(2),
                  'R\$ ${a.precoPorLitro.toStringAsFixed(2)}',
                  a.kmPorLitro.toStringAsFixed(2),
                  'R\$ ${a.totalGasto.toStringAsFixed(2)}',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 16),

            // Rodapé da Tabela no PDF
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey500),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Resumo e Médias do Mês ($nomeMes/$ano)',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    '• Total Gasto no Mês: R\$ ${totalGastoMes.toStringAsFixed(2)} (Média por abastecimento: R\$ ${mediaGastoPorAbastecimento.toStringAsFixed(2)})',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '• Média de KMs Rodados até o momento: ${mediaKmRodados.toStringAsFixed(1)} KM por abastecimento',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '• Média de Consumo (KM/Litro) até o momento: ${mediaKmPorLitro.toStringAsFixed(2)} KM/L',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text(
                    '• Diagnóstico de Consumo vs. Mercado: $statusConsumoMercado',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'consumo_${veiculo.placa}_${nomeMes}_$ano.pdf',
    );
  }
}
