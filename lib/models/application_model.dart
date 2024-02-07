class ApplicationModel {
  final String applicantId;
  final String jobId;
  final String proposalDescription;
  final DateTime applicationPostedTime;
  final String bidAmount;
  final String status;

  ApplicationModel({
    required this.applicantId,
    required this.jobId,
    required this.proposalDescription,
    required this.applicationPostedTime,
    required this.bidAmount,
    this.status = 'pending',
  });

  toJson() {
    return {
      "applicant_id": applicantId,
      "jobId": jobId,
      "proposal_description": proposalDescription,
      "applicationPostedTime": applicationPostedTime,
      "bid_amount": bidAmount,
      "status": status,
    };
  }
}
