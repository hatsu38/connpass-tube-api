import React, { Component } from 'react'
import PropTypes from 'prop-types'
import EventCards from '../components/EventCards'

const propTypes = {
  tag: PropTypes.object.isRequired
}

export default class TagRelatedEvent extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const tag = this.props.tag
    const events = this.props.tag.events
    return (
      <>
        <div className="border-top">
          <div className="white--background mt-20 mb-0 pt-20 pb-20 pl-20 pr-20 border-bottom display-flex">
            <h2 className="f4 section-title-main-text marginless">
              <a href={'/tags/' + tag.id} className="gray--800">#{tag.name}</a>
            </h2>
            <p className="link--text marginless">
              <a href={'/tags/' + tag.id}>
                もっと見る
              </a>
            </p>
          </div>
          {events && <EventCards events={events} />}
        </div>
      </>
    )
  }
}

TagRelatedEvent.propTypes = propTypes