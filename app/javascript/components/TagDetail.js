import React, { Component } from 'react'
import axios from 'axios'
import PropTypes from 'prop-types'
import EventCards from '../components/EventCards'
import PageTitle from '../components/PageTitle'
import Hr from '../components/Hr'

const REQUEST_API_BASE_URL = "/api/v1/tags/"

const propTypes = {
  tag: PropTypes.object.isRequired,
}

export default class TagDetail extends Component {
  constructor(props) {
    super(props);
    this.state = {
      events: [],
      totalCount: 0
    }
  }

  componentDidMount() {
    this.fetchTags()
  }

  async fetchTags() {
    console.log("this.props.params.route", this.props.tag.id)
    const api = `${REQUEST_API_BASE_URL}/${this.props.tag.id}`
    const apiResponse = await axios.get(api).catch(null)
    console.log("apiResponse", apiResponse)
    if(!apiResponse || !apiResponse.data || apiResponse.data.status === 500) { return true }

    const data = apiResponse.data
    console.log("data", data)
    const insertEvents = this.state.events.concat(data.events)
    this.setState({
      events: insertEvents,
      totalCount: data.total_count
    })
  }

  render() {
    const {tag} = this.props
    const {events, totalCount} = this.state
    console.log("=======EVENTS=======", events)
    return (
      <>
        <div className="white--background border-top">
          <PageTitle eventCount={totalCount} title={tag.name} />
          <Hr />
          {events && <EventCards events={events} />}
        </div>
      </>
    )
  }
}

TagDetail.propTypes = propTypes
