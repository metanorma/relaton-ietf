RSpec.describe RelatonIetf::RfcEntry do
  it "create instance and parse" do
    parser = double "parser"
    expect(parser).to receive(:parse).and_return(:bibitem)
    expect(RelatonIetf::RfcEntry).to receive(:new).with(:doc).and_return parser
    expect(RelatonIetf::RfcEntry.parse(:doc)).to be :bibitem
  end

  context "instance methods" do
    let(:doc) do
      idx = Nokogiri::XML File.read "spec/examples/ietf_rfcsubseries.xml", encoding: "UTF-8"
      idx.at "/xmlns:rfc-index/xmlns:rfc-entry"
    end

    subject { RelatonIetf::RfcEntry.new(doc) }

    it "initialize" do
      expect(subject).to be_instance_of RelatonIetf::RfcEntry
      expect(subject.instance_variable_get(:@doc)).to be doc
    end

    it "parse doc" do
      expect(subject).to receive(:parse_docid)
      expect(subject).to receive(:code)
      expect(subject).to receive(:parse_title)
      expect(subject).to receive(:parse_link)
      expect(subject).to receive(:parse_date)
      expect(subject).to receive(:parse_contributor)
      expect(subject).to receive(:parse_keyword)
      expect(subject).to receive(:parse_abstract)
      expect(subject).to receive(:parse_relation)
      expect(subject).to receive(:parse_status)
      expect(subject).to receive(:parse_editorialgroup)
      expect(RelatonIetf::IetfBibliographicItem).to receive(:new).and_return :bib
      expect(subject.parse).to be :bib
    end

    it "parse docid" do
      did = subject.parse_docid
      expect(did).to be_instance_of Array
      expect(did.size).to be 2
      expect(did[0]).to be_instance_of RelatonBib::DocumentIdentifier
      expect(did[0].type).to eq "IETF"
      expect(did[0].id).to eq "IETF RFC1139"
      expect(did[1].type).to eq "DOI"
      expect(did[1].id).to eq "10.17487/RFC1139"
    end

    it "parse title" do
      title = subject.parse_title
      expect(title).to be_instance_of Array
      expect(title.size).to be 1
      expect(title[0]).to be_instance_of RelatonBib::TypedTitleString
      expect(title[0].type).to eq "main"
      expect(title[0].title.content).to eq "Echo function for ISO 8473"
    end

    it "parse link" do
      link = subject.parse_link
      expect(link).to be_instance_of Array
      expect(link.size).to be 1
      expect(link[0]).to be_instance_of RelatonBib::TypedUri
      expect(link[0].type).to eq "src"
      expect(link[0].content.to_s).to eq "https://www.rfc-editor.org/info/rfc1139"
    end

    it "parse date" do
      date = subject.parse_date
      expect(date).to be_instance_of Array
      expect(date.size).to be 1
      expect(date[0]).to be_instance_of RelatonBib::BibliographicDate
      expect(date[0].type).to eq "published"
      expect(date[0].on).to eq "1990-01"
    end

    it "parse contributor" do
      contr = subject.parse_contributor
      expect(contr).to be_instance_of Array
      expect(contr.size).to be 1
      expect(contr[0]).to be_instance_of RelatonBib::ContributionInfo
      expect(contr[0].role[0].type).to eq "author"
      expect(contr[0].entity).to be_instance_of RelatonBib::Person
      expect(contr[0].entity.name.completename.content).to eq "R.A. Hagens"
    end

    it "parse keyword" do
      kw = subject.parse_keyword
      expect(kw).to be_instance_of Array
      expect(kw.size).to be 4
      expect(kw[0]).to eq "IPv6"
    end

    it "parse abstract" do
      abs = subject.parse_abstract
      expect(abs).to be_instance_of Array
      expect(abs.size).to be 1
      expect(abs[0]).to be_instance_of RelatonBib::FormattedString
      expect(abs[0].content).to include "This memo defines an echo function"
    end

    it "parse relation" do
      rel = subject.parse_relation
      expect(rel).to be_instance_of Array
      expect(rel.size).to be 2
      expect(rel[0]).to be_instance_of RelatonBib::DocumentRelation
      expect(rel[0].type).to eq "obsoletedBy"
      expect(rel[0].bibitem.formattedref.content).to eq "RFC1574"
    end

    it "parse status" do
      expect(subject.parse_status.stage.value).to eq "PROPOSED STANDARD"
    end

    it "parse editorialgroup" do
      eg = subject.parse_editorialgroup
      expect(eg).to be_instance_of RelatonBib::EditorialGroup
      expect(eg.technical_committee[0].workgroup.name).to eq "osigen"
    end
  end
end
