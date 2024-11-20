class MetasploitModule < Msf::Auxiliary
  def initialize(info = {})
    super(
      update_info(
        info,
        'Name' => 'Ping và Quét IP (Ping and Scan IP)',
        'Description' => 'Module thực hiện lệnh ping đến địa chỉ IP và quét cổng của nó, hiển thị kết quả bằng tiếng Việt.',
        'Author' => ['Mai Việt'],
        'License' => MSF_LICENSE,
        'Actions' => [
          ['Ping và Quét', { 'Description' => 'Thực hiện lệnh ping và quét cổng đến mục tiêu' }]
        ],
        'DefaultAction' => 'Ping và Quét'
      )
    )

    register_options(
      [
        Opt::RHOST(), # Địa chỉ IP mục tiêu
        OptInt.new('TIMEOUT', [true, 'Thời gian chờ (giây)', 5]) # Thời gian chờ
      ]
    )
  end

  def run
    rhost = datastore['RHOST']
    timeout = datastore['TIMEOUT']

    unless rhost
      print_error('Bạn phải chỉ định RHOST (địa chỉ IP mục tiêu).')
      return
    end

    # Thực hiện lệnh ping
    print_status("Đang thực hiện lệnh ping đến #{rhost} với thời gian chờ là #{timeout} giây...")

    begin
      result = `ping -c 1 -w #{timeout} #{rhost}`
      if $?.exitstatus == 0
        print_good("Ping thành công đến #{rhost}!")
      else
        print_error("Không thể ping đến #{rhost}.")
        return
      end
    rescue StandardError => e
      print_error("Đã xảy ra lỗi khi thực hiện lệnh ping: #{e.message}")
      return
    end

    # Thực hiện quét cổng bằng nmap
    print_status("--------------------------------------------------------------------------------")
    print_status("Đang thực hiện quét cổng với nmap đến #{rhost}...")

    begin
      nmap_result = `nmap #{rhost}` # Quét tất cả các cổng
      if $?.exitstatus == 0
        print_good("Kết quả quét cổng cho #{rhost}:")
        print_good(nmap_result)
      else
        print_error("Quá trình quét cổng không thành công.")
      end
    rescue StandardError => e
      print_error("Đã xảy ra lỗi khi thực hiện quét cổng với nmap: #{e.message}")
    end

    # Dự đoán tấn công
    print_status("--------------------------------------------------------------------------------")
    print_status("Dự đoán tấn công với các cổng mở:")

    # Danh sách các cổng phổ biến và lỗ hổng tương ứng
    port_vulns = {
      135 => {
        'description' => 'Cổng 135 (MS RPC) mở, có thể tấn công qua các lỗ hổng liên quan đến MS RPC.',
        'CVEs' => ['CVE-2020-0601 (Windows CryptoAPI)', 'CVE-2019-0708 (BlueKeep)', 'CVE-2020-1472 (Zerologon)'],
        'metasploit_modules' => ['exploit/windows/dcerpc/ms03_026_dcom', 'exploit/windows/dcerpc/ms17_010_eternalblue']
      },
      139 => {
        'description' => 'Cổng 139 (NetBIOS) mở, có thể tấn công qua SMBv1 hoặc lỗ hổng EternalBlue.',
        'CVEs' => ['CVE-2017-0144 (EternalBlue)', 'CVE-2017-0145'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'auxiliary/scanner/smb/smb_version']
      },
      445 => {
        'description' => 'Cổng 445 (Microsoft DS) mở, có thể tấn công qua SMBv1 hoặc EternalBlue.',
        'CVEs' => ['CVE-2017-0144 (EternalBlue)', 'CVE-2020-0796 (SMBGhost)', 'CVE-2019-0708 (BlueKeep)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'exploit/windows/smb/smbghost']
      },
      # Thêm các cổng khác ở đây...
      5357 => {
        'description' => 'Cổng 5357 mở, có thể bị tấn công qua lỗ hổng SMB hoặc các dịch vụ mạng trong Windows.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2019-0708 (BlueKeep)'],
        'metasploit_modules' => ['exploit/windows/smb/smbghost', 'auxiliary/scanner/smb/smb_version']
      },
      49152 => {
        'description' => 'Cổng 49152 mở, có thể có lỗ hổng liên quan đến dịch vụ RPC hoặc các dịch vụ không bảo mật khác trong Windows.',
        'CVEs' => ['CVE-2020-0796', 'CVE-2019-0708'],
        'metasploit_modules' => ['exploit/windows/dcerpc/ms03_026_dcom', 'auxiliary/scanner/msrpc/ms10_061_rpc_dcom_dos']
      },
      49153 => {
        'description' => 'Cổng 49153 mở, có thể có lỗ hổng trong các dịch vụ RPC hoặc SMBv1.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2017-0144 (EternalBlue)', 'CVE-2020-0601'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'exploit/windows/dcerpc/ms03_026_dcom']
      },
      49154 => {
        'description' => 'Cổng 49154 mở, có thể có lỗ hổng trong các dịch vụ RPC hoặc SMB.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2017-0144 (EternalBlue)', 'CVE-2020-1472 (Zerologon)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'exploit/windows/dcerpc/ms03_026_dcom']
      },
      49155 => {
        'description' => 'Cổng 49155 mở, có thể có lỗ hổng trong các dịch vụ RPC hoặc SMB không bảo mật.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2019-0708 (BlueKeep)', 'CVE-2017-0144 (EternalBlue)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'auxiliary/scanner/msrpc/ms10_061_rpc_dcom_dos']
      },
      49156 => {
        'description' => 'Cổng 49156 mở, có thể có lỗ hổng trong các dịch vụ SMBv1 hoặc RPC.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2017-0144 (EternalBlue)', 'CVE-2020-0601 (Windows CryptoAPI)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'auxiliary/scanner/smb/smb_version']
      },
      49157 => {
        'description' => 'Cổng 49157 mở, có thể có lỗ hổng liên quan đến RPC hoặc SMB trên Windows.',
        'CVEs' => ['CVE-2020-0796 (SMBGhost)', 'CVE-2019-0708 (BlueKeep)', 'CVE-2020-1472 (Zerologon)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue', 'auxiliary/scanner/msrpc/ms10_061_rpc_dcom_dos']
      },
      21 => {
        'description' => 'Cổng 21 (FTP) mở, có thể tấn công qua lỗ hổng liên quan đến FTP như CVE-2019-11510.',
        'CVEs' => ['CVE-2019-11510'],
        'metasploit_modules' => ['auxiliary/scanner/ftp/ftp_version', 'auxiliary/scanner/ftp/ftp_anonymous']
      },
      22 => {
        'description' => 'Cổng 22 (SSH) mở, có thể tấn công qua brute force hoặc lỗ hổng SSH.',
        'CVEs' => ['CVE-2018-15473'],
        'metasploit_modules' => ['auxiliary/scanner/ssh/ssh_version', 'auxiliary/scanner/ssh/ssh_brute']
      },
      53 => {
        'description' => 'Cổng 53 (DNS) mở, có thể tấn công qua DNS amplification hoặc lỗ hổng DNS.',
        'CVEs' => ['CVE-2017-3143', 'CVE-2020-1350'],
        'metasploit_modules' => ['auxiliary/scanner/dns/dns_version']
      },
      80 => {
        'description' => 'Cổng 80 (HTTP) mở, có thể tấn công qua các lỗ hổng như SQL Injection, XSS, LFI.',
        'CVEs' => ['CVE-2019-11043', 'CVE-2017-5638'],
        'metasploit_modules' => ['auxiliary/scanner/http/http_version', 'auxiliary/scanner/http/dir_scanner']
      },
      110 => {
        'description' => 'Cổng 110 (POP3) mở, có thể tấn công qua brute force hoặc các lỗ hổng POP3.',
        'CVEs' => ['CVE-2017-12212'],
        'metasploit_modules' => ['auxiliary/scanner/pop3/pop3_login']
      },
      143 => {
        'description' => 'Cổng 143 (IMAP) mở, có thể tấn công qua brute force hoặc lỗ hổng IMAP.',
        'CVEs' => ['CVE-2018-10257'],
        'metasploit_modules' => ['auxiliary/scanner/imap/imap_login']
      },
      443 => {
        'description' => 'Cổng 443 (HTTPS) mở, có thể tấn công qua các lỗ hổng SSL/TLS hoặc brute force.',
        'CVEs' => ['CVE-2014-3566', 'CVE-2014-0224'],
        'metasploit_modules' => ['auxiliary/scanner/ssl/openssl_heartbleed', 'auxiliary/scanner/http/ssl_version']
      },
      587 => {
        'description' => 'Cổng 587 (SMTP Submission) mở, có thể tấn công qua lỗ hổng SMTP hoặc brute force.',
        'CVEs' => ['CVE-2016-6170'],
        'metasploit_modules' => ['auxiliary/scanner/smtp/smtp_brute']
      },
      993 => {
        'description' => 'Cổng 993 (IMAPS) mở, có thể tấn công qua lỗ hổng IMAPS hoặc brute force.',
        'CVEs' => ['CVE-2018-10257'],
        'metasploit_modules' => ['auxiliary/scanner/imap/imap_login']
      },
      995 => {
        'description' => 'Cổng 995 (POP3S) mở, có thể tấn công qua lỗ hổng POP3S hoặc brute force.',
        'CVEs' => ['CVE-2017-12212'],
        'metasploit_modules' => ['auxiliary/scanner/pop3/pop3_login']
      },
      3306 => {
        'description' => 'Cổng 3306 (MySQL) mở, có thể tấn công qua brute force hoặc SQL Injection.',
        'CVEs' => ['CVE-2012-2122', 'CVE-2012-5613'],
        'metasploit_modules' => ['auxiliary/scanner/mysql/mysql_login', 'auxiliary/scanner/mysql/mysql_enum']
      },
      3389 => {
        'description' => 'Cổng 3389 (RDP) mở, có thể tấn công qua brute force hoặc lỗ hổng RDP.',
        'CVEs' => ['CVE-2019-0708 (BlueKeep)', 'CVE-2020-0609'],
        'metasploit_modules' => ['auxiliary/scanner/rdp/rdp_scanner', 'exploit/windows/rdp/ms12_020_maxchannelid']
      },
      4444 => {
        'description' => 'Cổng 4444 (MSRPC) mở, có thể tấn công qua lỗ hổng MSRPC.',
        'CVEs' => ['CVE-2017-0143 (EternalBlue)', 'CVE-2020-1472 (Zerologon)'],
        'metasploit_modules' => ['exploit/windows/smb/ms17_010_eternalblue']
      },
      5900 => {
        'description' => 'Cổng 5900 (VNC) mở, có thể tấn công qua brute force hoặc lỗ hổng VNC.',
        'CVEs' => ['CVE-2005-1669'],
        'metasploit_modules' => ['auxiliary/scanner/vnc/vnc_login']
      },
      8080 => {
        'description' => 'Cổng 8080 (HTTP Proxy) mở, có thể tấn công qua các lỗ hổng web như RFI, LFI.',
        'CVEs' => ['CVE-2019-11043'],
        'metasploit_modules' => ['auxiliary/scanner/http/http_version']
      },
      8081 => {
        'description' => 'Cổng 8081 (HTTP Proxy) mở, có thể tấn công qua các lỗ hổng HTTP Proxy.',
        'CVEs' => ['CVE-2018-11776'],
        'metasploit_modules' => ['auxiliary/scanner/http/http_version']
      },
      8888 => {
        'description' => 'Cổng 8888 (HTTP Proxy) mở, có thể tấn công qua các lỗ hổng Proxy.',
        'CVEs' => ['CVE-2019-11043'],
        'metasploit_modules' => ['auxiliary/scanner/http/http_version']
        }
      }

    # Lọc các cổng mở từ kết quả quét nmap
    open_ports = nmap_result.scan(/(\d+)\/tcp\s+open/).flatten.map(&:to_i)

    # Hiển thị dự đoán tấn công cho các cổng mở
    open_ports.each do |port|
      if port_vulns[port]
        # In mô tả cổng
        print_good(port_vulns[port]['description'])
        # In CVE
        print_good(" -> Các CVE liên quan: #{port_vulns[port]['CVEs'].join(', ')}")
        # In các module Metasploit
        print_good(" -> Các module Metasploit liên quan: #{port_vulns[port]['metasploit_modules'].join(', ')}")
      else
        print_warning("Cổng #{port} mở nhưng chưa có lỗ hổng dự đoán.")
      end
    end
  end
end
