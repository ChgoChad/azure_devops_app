import 'package:azure_devops/src/models/pipeline.dart';
import 'package:flutter/material.dart';

extension PipelineStatusExtColor on PipelineStatus {
  Color get color {
    switch (this) {
      case PipelineStatus.notStarted:
        return Colors.blue;
      case PipelineStatus.cancelling:
        return Colors.blue;
      case PipelineStatus.inProgress:
        return Colors.blue;
      case PipelineStatus.completed:
        return Colors.blue;
      case PipelineStatus.postponed:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }
}

extension PipelineResultExtColor on PipelineResult {
  Color get color {
    switch (this) {
      case PipelineResult.canceled:
        return Colors.grey;
      case PipelineResult.failed:
        return Colors.red;
      case PipelineResult.none:
        return Colors.grey;
      case PipelineResult.partiallySucceeded:
        return Colors.cyanAccent;
      case PipelineResult.succeeded:
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }
}
