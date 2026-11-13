import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/veiculo.dart';
import '../models/abastecimento.dart';

class PdfService {
  static final PdfColor _verdeEletrico = PdfColor.fromInt(0xFF00D084);
  static final PdfColor _verdeProfundo = PdfColor.fromInt(0xFF0B3D2E);
  static final PdfColor _cinzaSecundario = PdfColor.fromInt(0xFF6B7280);

  static Future<void> gerarPdfDoMes({
    required Veiculo veiculo,
    required String nomeMes,
    required int ano,
    required List<Abastecimento> abastecimentos,
    required double totalGastoMes,
    required double mediaGastoPorAbastecimento,
    required double somaKmRodados,
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
                      color: _verdeProfundo,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Referência de Mercado cadastrada: Gasolina ${veiculo.mediaMercadoGasolina.toStringAsFixed(1)} KM/L | Álcool ${veiculo.mediaMercadoAlcool.toStringAsFixed(1)} KM/L',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _cinzaSecundario,
                    ),
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
                'Combust.',
                'KM Ant.',
                'KM Atual',
                'KM Rod.',
                'Tanque Ant.',
                'Tanque Atual',
                'KM Efetivo',
                'Litros',
                'R\$/L',
                'KM/L',
                'Total (R\$)',
              ],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8.5,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(
                color: _verdeProfundo,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.center,
              data: abastecimentos.map((a) {
                return [
                  a.data,
                  a.posto,
                  a.tipoCombustivel,
                  a.kmAnterior.toStringAsFixed(1),
                  a.kmAtual.toStringAsFixed(1),
                  a.kmRodados.toStringAsFixed(1),
                  '${a.kmRestanteTanqueAnterior.toStringAsFixed(0)} KM',
                  '${a.kmRestanteTanqueAtual.toStringAsFixed(0)} KM',
                  a.kmEfetivoConsumo.toStringAsFixed(1),
                  a.litros.toStringAsFixed(2),
                  'R\$ ${a.precoPorLitro.toStringAsFixed(2)}',
                  a.kmPorLitro.toStringAsFixed(2),
                  'R\$ ${a.totalGasto.toStringAsFixed(2)}',
                ];
              }).toList(),
            ),

            pw.SizedBox(height: 16),

            // Rodapé da Tabela no PDF com Tópicos e Subtópicos espaçados
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: _verdeEletrico, width: 1.5),
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
                      color: _verdeProfundo,
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Tópico 1
                  pw.Text(
                    '• Total Gasto no Mês: R\$ ${totalGastoMes.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14, top: 2),
                    child: pw.Text(
                      '- Média por abastecimento: R\$ ${mediaGastoPorAbastecimento.toStringAsFixed(2)}',
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                  pw.SizedBox(height: 6),

                  // Tópico 2
                  pw.Text(
                    '• Quilometragem Rodada até o momento:',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14, top: 2),
                    child: pw.Text(
                      '- Total rodado no mês: ${somaKmRodados.toStringAsFixed(1)} KM',
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14, top: 2),
                    child: pw.Text(
                      '- Média de KMs por abastecimento: ${mediaKmRodados.toStringAsFixed(1)} KM',
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                  pw.SizedBox(height: 6),

                  // Tópico 3
                  pw.Text(
                    '• Média de Consumo (KM/Litro) até o momento: ${mediaKmPorLitro.toStringAsFixed(2)} KM/L',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 14, top: 2),
                    child: pw.Text(
                      '- Referência de mercado do veículo: Gasolina ${veiculo.mediaMercadoGasolina.toStringAsFixed(1)} KM/L | Álcool ${veiculo.mediaMercadoAlcool.toStringAsFixed(1)} KM/L',
                      style: const pw.TextStyle(fontSize: 9.5),
                    ),
                  ),
                  pw.SizedBox(height: 8),

                  // Diagnóstico
                  pw.Text(
                    'Diagnóstico de Consumo vs. Mercado: $statusConsumoMercado',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _verdeProfundo,
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