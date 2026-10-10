Pod::Spec.new do |spec|
  spec.name = 'TableRowKit'
  spec.version = '0.1.2'
  spec.summary = 'Row and section models for UIKit table views.'
  spec.description = 'An Objective-C UITableView data source and delegate adapter built around ordered row and section models.'
  spec.homepage = 'https://github.com/OrisunWang/TableRowKit'
  spec.source = { :git => 'https://github.com/OrisunWang/TableRowKit.git', :tag => "v#{spec.version}" }
  spec.ios.deployment_target = '15.0'
  spec.source_files = 'Sources/TableRowKit/**/*.{h,m}'
  spec.public_header_files = 'Sources/TableRowKit/{TableRowKit,TRKNode,TRKTableDataSource,TRKTableSection,TRKTableRow,TRKTableView,TRKTableViewCell}.h'
  spec.private_header_files = 'Sources/TableRowKit/TRKTableViewDelegateProxy.h'
  spec.framework = 'UIKit'
  spec.requires_arc = true

  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = 'TableRowKit contributors'

  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{h,m,swift}'
    test_spec.framework = 'XCTest'
  end
end
