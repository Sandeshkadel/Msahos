import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/models/transfer_job.dart';
import '../../core/services/mesh_controller.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key, required this.controller});

  final MeshController controller;

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.controller.jobs;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('File Relay', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Chunked transfer with resume-ready progress tracking.'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () {
                  widget.controller.queueTransfer('site-design.fig', 5 * 1024 * 1024);
                },
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Send 5 MB file'),
              ),
              FilledButton.icon(
                onPressed: () {
                  widget.controller.queueTransfer('offline-map.mbtiles', 38 * 1024 * 1024);
                },
                icon: const Icon(Icons.map),
                label: const Text('Send map pack'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: jobs.isEmpty
                ? const Center(child: Text('No active transfers.'))
                : ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) => _TransferCard(job: jobs[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TransferCard extends StatelessWidget {
  const _TransferCard({required this.job});

  final TransferJob job;

  @override
  Widget build(BuildContext context) {
    final percent = (job.progress * 100).toStringAsFixed(0);
    final mbSent = (job.sentBytes / (1024 * 1024)).toStringAsFixed(2);
    final mbTotal = (job.totalBytes / (1024 * 1024)).toStringAsFixed(2);
    final speed = max(0.35, job.progress * 7.5).toStringAsFixed(2);

    return Card(
      color: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.fileName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: job.progress),
            const SizedBox(height: 8),
            Text('Progress $percent%   $mbSent / $mbTotal MB   ${speed}MB/s'),
            Text('State ${job.state.name.toUpperCase()}'),
          ],
        ),
      ),
    );
  }
}
